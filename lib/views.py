from student.models import Student
from warden.models import Warden
from django.shortcuts import get_object_or_404
from home.models import Outpass,OPRecord,OTP,OPRalias
from tutor.models import Tutor
from django.core.exceptions import PermissionDenied
from security.models import Security
from django.http import Http404,HttpResponse
import json
import random
import requests as http
import threading
from oauth2client.service_account import ServiceAccountCredentials
from django.views.decorators.csrf import csrf_exempt
from django.core.paginator import Paginator
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.authentication import TokenAuthentication
from django.contrib.auth.models import User
from django.core.exceptions import SuspiciousOperation
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
import datetime
import pytz
import time

def get_bearer_token():
    SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']
    credentials = ServiceAccountCredentials.from_json_keyfile_name('api/key.json',SCOPES)
    access_token_info = credentials.get_access_token()
    return access_token_info.access_token

def request_notification(student,to):
    tokens = []
    if to == 'tutor':
        tokens = [tutor.device_id for tutor in student.tutors.all() if not tutor.device_id == None]
    if to == 'warden':
        tokens = [warden.device_id for warden in student.wardens.all() if not warden.device_id == None]
    for token in tokens:
        headers = {
        'Content-Type':'application/json',
        'Authorization': f'Bearer {get_bearer_token()}'
        }
        body={
        "message":{
        "token" : str(token),
        "notification" : {
        "body" : f"you got a new outpass request from {student.user.username}",
        "title" : "New Request",
        },
          "android": {
            "notification": {
                "sound": "default"
            }
        },
        }
        }
        response = http.post('https://fcm.googleapis.com/v1/projects/outpass-58be4/messages:send',
        json=body,
        headers=headers
        )
        print(response)

def status_notification(student,status,by):
    if not student.device_id == None:
        headers = {
        'Content-Type':'application/json',
        'Authorization': f'Bearer {get_bearer_token()}'
        }
        body={
        "message":{
        "token" : str(student.device_id),
        "notification" : {
        "body" : f"your outpass was {status} by {by}",
        "title" : f"{status}".upper(),
        },
          "android": {
            "notification": {
                "sound": "default"
            }
        },
        }
        }
        response = http.post('https://fcm.googleapis.com/v1/projects/outpass-58be4/messages:send',
        json=body,
        headers=headers
        )
        print(response)
def get_otp():
    otp = str(random.randrange(10000,99999))
    otps= [otp.otp for otp in OTP.objects.all()]
    while otp in otps:
        otp = str(random.randrange(1000,9999))
    return otp

def get_record_no():
    opr_no = str(random.randrange(10000,99999))
    oprs = [alias.alias_no for alias in OPRalias.objects.all()]
    while opr_no in oprs:
        opr_no = str(random.randrange(10000,99999))
    return opr_no

class LoginView(APIView):
    def post(self, request):
        stu = False
        war = False
        tut = False
        sec = False
        try:
            if(request.POST.get('role') == "student"): 
                user = Student.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
                stu = True
            elif(request.POST.get('role') == "warden"): 
                user = Warden.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
                war = True
            elif(request.POST.get('role') == "tutor"):
                user = Tutor.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
                tut = True
            elif(request.POST.get('role') == "security"): 
                user = Security.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
                sec = True
            
        except:
            raise SuspiciousOperation("wrong credentials")
        else:
            user = authenticate(request, 
            username=user.username, 
            password=request.POST.get('password')
            )
            if user is None:
                raise SuspiciousOperation("wrong credentials")
            if(stu):
                user.student.device_id = request.POST.get('deviceId')
                user.student.save()
            if(war):
                user.warden.device_id = request.POST.get('deviceId')
                user.warden.save()
            if(tut):
                user.tutor.device_id = request.POST.get('deviceId')
                user.tutor.save()
            if(sec):
                user.security.device_id = request.POST.get('deviceId')
                user.security.save()
            token,created = Token.objects.get_or_create(user=user)
            return Response({'token':token.key})

class StudentOutpassView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)
    def get(self, request):
        try:
            student = request.user.student
        except:
            return SuspiciousOperation
        else:
            outpass = student.outpass_set.first()
            if not outpass == None:
                tz = pytz.timezone('Asia/Kolkata')
                record_no = None
                otp = None
                if not outpass.otp_set.first() == None:
                    otp = outpass.otp_set.first().otp
                if not outpass.opralias_set.first() == None:
                    record_no = outpass.opralias_set.first().alias_no
                return Response({'outpass':{
                    'pk':outpass.pk,
                    'req-time': outpass.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'dep-time': outpass.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'req-days': outpass.req_days,
                    'reason': outpass.reason.replace('\n','').replace('\r',''),
                    'tutor': outpass.tutor_status,
                    'warden': outpass.warden_status,
                    'security': outpass.security_status,
                    'otp':otp,
                    'record_no':record_no,
                    'expired':outpass.expired
                }})
            return Response({'outpass':''})

    def post(self, request):
        try:
            student = request.user.student
        except:
            raise SuspiciousOperation
        else:
            if student.outpass_set.count() == 0:
                date = request.POST.get('dep-date').replace('/', ' ')
                tz = pytz.timezone('Asia/Kolkata')
                date = tz.localize(dt=datetime.datetime.strptime(date, r'%d %m %Y %I:%M %p'))
                now = tz.localize(dt=(datetime.datetime.now() - datetime.timedelta(minutes=5)))
                date_limit = tz.localize(dt=(datetime.datetime.now() + datetime.timedelta(days=4)))
                if date > now and date < date_limit:
                    outpass = Outpass()
                    outpass.student = request.user.student
                    outpass.tutor_status = 'pending'
                    outpass.warden_status = 'pending'
                    outpass.security_status = 'pending'
                    outpass.reason = request.POST.get('reason')
                    outpass.dep_date = date
                    outpass.req_days = request.POST.get('req-days')
                    outpass.save()
                    for warden in request.user.student.wardens.all():
                        outpass.wardens.add(warden)
                    for tutor in request.user.student.tutors.all():
                        outpass.tutors.add(tutor)
                    outpass.save()
                    th = threading.Thread(target=request_notification,args=(request.user.student,'tutor'))
                    th.start()
                    return Response()
                else:
                    raise SuspiciousOperation

    def put(self, request):
        try:
            student = request.user.student
        except:
            raise SuspiciousOperation
        else:
            outpass = get_object_or_404(Outpass,pk=json.loads(request.body)['pk'])
            if json.loads(request.body)['task'] == 'otp':
                if not outpass.student.pk == request.user.student.pk:
                    raise PermissionDenied
                elif not outpass.tutor_status == 'accepted' and not outpass.tutor_status == 'accepted' and outpass.expired:
                    raise PermissionDenied
                elif outpass.otp_set.count() >= 1:
                    raise PermissionDenied
                else:
                    otp = OTP(
                    otp = get_otp(),
                    outpass = outpass
                    )
                    otp.save()
                    outpass.expired = True
                    outpass.save()
                    return Response()
                    
            elif json.loads(request.body)['task'] == 'delete':   
                if outpass.student.pk == request.user.student.pk:
                    outpass.delete()
                    return Response()
            else:
                raise SuspiciousOperation

class TutorOutpassView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)
    def get(self, request):
        try:
            tutor = request.user.tutor
        except:
            raise SuspiciousOperation
        else:
            tz = pytz.timezone('Asia/Kolkata')
            outpass_pages = Paginator(
                [outpass for outpass in request.user.tutor.tutor_outpass.all().order_by('dep_date') if outpass.tutor_status == 'pending'],
                3 
            )
            if int(request.GET.get('page')) > outpass_pages.num_pages or int(request.GET.get('page')) < 1:
                raise Http404
            return Response({
                'outpass':[
                    {   'pk':outpass.pk,
                        'student':outpass.student.user.username,
                        'req-date':outpass.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                        'dep-date':outpass.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                        'req-days':outpass.req_days,
                        'reason':outpass.reason
                    }
                for outpass in outpass_pages.page(int(request.GET.get('page'))).object_list]
            })

    def put(self, request):
        try:
            tutor = request.user.tutor
        except:
            raise SuspiciousOperation
        else:
            if(json.loads(request.body)['task'] == 'acceptall'):
                outpasses = [outpass for outpass in request.user.tutor.tutor_outpass.all().order_by('dep_date') if outpass.tutor_status == 'pending']
                for outpass in outpasses:
                    outpass.tutor_status = 'accepted'
                    outpass.accepted_tutor = request.user.tutor
                    outpass.save()
                    th1 = threading.Thread(target=request_notification,args=(outpass.student,'warden'))
                    th2 = threading.Thread(target=status_notification,args=(outpass.student,'accepted','tutor'))
                    th1.start()
                    th2.start()
                return Response()
            outpass = get_object_or_404(Outpass,pk=json.loads(request.body)['pk'])
            if request.user.tutor in outpass.tutors.all() and outpass.tutor_status == 'pending':
                if(json.loads(request.body)['task'] == 'accept'):
                    outpass.tutor_status = 'accepted'
                    outpass.accepted_tutor = request.user.tutor
                    outpass.save()
                    th1 = threading.Thread(target=request_notification,args=(outpass.student,'warden'))
                    th2 = threading.Thread(target=status_notification,args=(outpass.student,'accepted','tutor'))
                    th1.start()
                    th2.start()
                    return Response()
                elif(json.loads(request.body)['task'] == 'reject'):
                    outpass.tutor_status = 'rejected'
                    outpass.accepted_tutor = request.user.tutor
                    outpass.expired = True
                    outpass.save()
                    th = threading.Thread(target=status_notification,args=(outpass.student,'rejected','tutor'))
                    th.start()
                    return Response()
            else:
                raise PermissionDenied

class TutorLogView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def get(self, request):
        try:
            tu = request.user.tutor
        except:
            raise PermissionDenied
        else:
            date = request.GET.get('date').split('/')
            records = OPRecord.objects.filter(dep_date__year=date[2],dep_date__month=date[1],dep_date__day=date[0],tutors__in=[request.user.tutor]).order_by('-dep_date')
            tz = pytz.timezone('Asia/Kolkata')
            record_pages = Paginator(records,12)
            if int(request.GET.get('page')) > record_pages.num_pages or int(request.GET.get('page')) < 1:
                raise Http404
            return Response({'records':[
                {   'pk':record.pk,
                    'name':record.student.user.username,
                    'dep-date':record.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'emergency':record.emergency
                }
            for record in record_pages.page(int(request.GET.get('page'))).object_list]})

class TutorLogDetail(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def post(self, request):
        try:
            tu = request.user.tutor
        except:
            raise PermissionDenied
        else:
            tz = pytz.timezone('Asia/Kolkata')
            record = get_object_or_404(OPRecord, pk=request.POST.get('pk'))
            in_time = None
            if not request.user.tutor in record.tutors.all():
                raise PermissionDenied
            if not record.in_time == None:
                in_time = record.in_time.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p')
            return Response({'record':{
                'name':record.student.user.username,
                'acc-warden':record.accepted_warden.user.username,
                'acc-tutor':record.accepted_tutor.user.username,
                'acc-sec':record.accepted_security.user.username,
                'req_date':record.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                'dep_date':record.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                'reason':record.reason,
                'req_days':record.req_days,
                'in_time':in_time,
                'emergency':record.emergency
            }})

class WardenLogView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def get(self, request):
        try:
            war = request.user.warden
        except:
            raise PermissionDenied
        else:
            date = request.GET.get('date').split('/')
            records = OPRecord.objects.filter(dep_date__year=date[2],dep_date__month=date[1],dep_date__day=date[0],wardens__in=[request.user.warden]).order_by('-dep_date')
            tz = pytz.timezone('Asia/Kolkata')
            record_pages = Paginator(records,12)
            if int(request.GET.get('page')) > record_pages.num_pages or int(request.GET.get('page')) < 1:
                raise Http404
            return Response({'records':[
                {   'pk':record.pk,
                    'name':record.student.user.username,
                    'dep-date':record.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'emergency':record.emergency
                }
            for record in record_pages.page(int(request.GET.get('page'))).object_list]})

class WardenLogDetail(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def post(self, request):
        try:
            tu = request.user.warden
        except:
            raise PermissionDenied
        else:
            tz = pytz.timezone('Asia/Kolkata')
            record = get_object_or_404(OPRecord, pk=request.POST.get('pk'))
            in_time = None
            if not request.user.warden in record.wardens.all():
                raise PermissionDenied
            if not record.in_time == None:
                in_time = record.in_time.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p')
            return Response({'record':{
                'name':record.student.user.username,
                'acc-warden':record.accepted_warden.user.username,
                'acc-tutor':record.accepted_tutor.user.username,
                'acc-sec':record.accepted_security.user.username,
                'req_date':record.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                'dep_date':record.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                'reason':record.reason,
                'req_days':record.req_days,
                'in_time':in_time,
                'emergency':record.emergency
            }})




class WardenOutpassView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def get(self, request):
        try:
            warden = request.user.warden
        except:
            raise SuspiciousOperation
        else:
            tz = pytz.timezone('Asia/Kolkata')
            all_outpass = [outpass for outpass in request.user.warden.warden_outpass.all().order_by('dep_date')
        if outpass.tutor_status == 'accepted' and outpass.warden_status == 'pending']
            outpass_pages = Paginator(all_outpass,3)
            if int(request.GET.get('page')) > outpass_pages.num_pages or int(request.GET.get('page')) < 1:
                raise Http404
            return Response({
                'outpass':[{
                    'pk':outpass.pk,
                    'student':outpass.student.user.username,
                    'req-date':outpass.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'dep-date':outpass.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'req-days':outpass.req_days,
                    'reason':outpass.reason
                }for outpass in outpass_pages.page(int(request.GET.get('page'))).object_list]
            })

    def put(self, request):
        try:
            tutor = request.user.warden
        except:
            raise SuspiciousOperation
        else:
            outpass = get_object_or_404(Outpass,pk=json.loads(request.body)['pk'])
            if request.user.warden in outpass.wardens.all() and outpass.tutor_status == 'accepted' and outpass.warden_status == 'pending':
                if(json.loads(request.body)['task'] == 'accept'):
                    outpass.accepted_warden = request.user.warden
                    outpass.warden_status = 'accepted'
                    outpass.save()
                    th = threading.Thread(target=status_notification,args=(outpass.student,'accepted','warden'))
                    th.run()
                    return Response()
                elif(json.loads(request.body)['task'] == 'reject'):
                    outpass.accepted_warden = request.user.warden
                    outpass.warden_status = 'rejected'
                    outpass.expired = True
                    outpass.save()
                    th = threading.Thread(target=status_notification,args=(outpass.student,'rejected','warden'))
                    th.run()
                    return Response()
            else:
                raise PermissionDenied

class WardenEmergencyOutpassView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def post(self, request):
        try:
            war = request.user.warden
        except:
            raise PermissionDenied
        else:
            try:
                user = User.objects.get(username=request.POST.get('reg_no'))
            except:
                raise Http404
            else:
                if user.student.outpass_set.count() > 0:
                    raise SuspiciousOperation
                tz = pytz.timezone('Asia/Kolkata')
                outpass = Outpass()
                outpass.student = user.student
                outpass.tutor_status = 'accepted'
                outpass.warden_status = 'accepted'
                outpass.accepted_tutor = user.student.tutors.first()
                outpass.accepted_warden = request.user.warden
                outpass.security_status = 'pending'
                outpass.reason = request.POST.get('reason')
                outpass.dep_date = tz.localize(dt=datetime.datetime.now())
                outpass.req_days = request.POST.get('reqDays')
                outpass.emergency = True
                outpass.save()
                for tutor in user.student.tutors.all():
                    outpass.tutors.add(tutor)
                for warden in user.student.wardens.all():
                    outpass.wardens.add(warden)
                outpass.save()
                otp = OTP(
                    otp = get_otp(),
                    outpass = outpass
                )
                otp.save()
                return Response()

class SecurityOutpassView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def post(self, request):
        try:
            sec = request.user.security
        except:
            raise PermissionDenied
        else:
            try:
                otp = OTP.objects.get(otp=request.POST.get('otp'))
            except:
                return Response({'outpass':{}})
            else:
                tz = pytz.timezone('Asia/Kolkata')
                return Response({'outpass':{
                    'student':otp.outpass.student.user.username,
                    'req-time': otp.outpass.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'dep-time': otp.outpass.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'req-days': otp.outpass.req_days,
                    'reason': otp.outpass.reason.replace('\n','').replace('\r',''),
                    'tutor': otp.outpass.tutor_status,
                    'warden': otp.outpass.warden_status,
                }})

    def put(self, request):
        try:
            sec = request.user.security
        except:
            raise PermissionDenied
        else:
            otp = json.loads(request.body).get('otp')
            task = json.loads(request.body).get('task')
            try:
                otp = OTP.objects.get(otp=otp)
            except:
                raise SuspiciousOperation
            else:
                if task == 'accept':
                    record = OPRecord()
                    record.student = otp.outpass.student
                    record.accepted_warden =  otp.outpass.accepted_warden
                    record.accepted_tutor = otp.outpass.accepted_tutor
                    record.req_date = otp.outpass.req_date
                    record.reason = otp.outpass.reason
                    record.req_days = otp.outpass.req_days
                    record.accepted_security = request.user.security
                    record.emergency = otp.outpass.emergency
                    record.save()
                    for tutor in otp.outpass.tutors.all():
                        record.tutors.add(tutor)
                    for warden in otp.outpass.wardens.all():
                        record.wardens.add(warden)
                    record.save()
                    otp.outpass.security_status = 'accepted'
                    otp.outpass.accepted_security = request.user.security
                    otp.outpass.expired = True
                    otp.outpass.save()
                    otp.outpass.otp_set.first().delete()
                    opra = OPRalias(
                        alias_no = get_record_no(),
                        opr = record,
                        outpass = otp.outpass
                    )
                    opra.save()
                    return Response()
                elif task == 'reject':
                    otp.outpass.security_status = 'rejected'
                    otp.outpass.accepted_security = request.user.security
                    otp.outpass.expired = True
                    otp.outpass.save()
                    otp.outpass.otp_set.first.delete()
                    return Response()
                else:
                    raise SuspiciousOperation

class SecurityRecordView(APIView):
    permission_classes = (IsAuthenticated,)
    authentication_classes = (TokenAuthentication,)

    def post(self, request):
        try:
            sec = request.user.security
        except:
            raise PermissionDenied
        else:
            try:
                record = OPRalias.objects.get(alias_no=request.POST.get('alias')).opr
            except:
                return Response({'record':{}})
            else:
                tz = pytz.timezone('Asia/Kolkata')
                return Response({'record':{
                'name':record.student.user.username,
                'acc-warden':record.accepted_warden.user.username,
                'acc-tutor':record.accepted_tutor.user.username,
                'acc-sec':record.accepted_security.user.username,
                'req_date':record.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                'dep_date':record.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                'reason':record.reason,
                'req_days':record.req_days 
            }})
    def put(self, request):
        try:
            sec = request.user.security
        except:
            raise PermissionDenied
        else:
            try:
                record = OPRalias.objects.get(alias_no=json.loads(request.body)['alias'])
            except:
                raise SuspiciousOperation

            else:
                tz = pytz.timezone('Asia/Kolkata')
                date = tz.localize(dt=datetime.datetime.now())
                record.opr.in_time = date
                record.opr.save()
                record.outpass.delete()
                record.delete()
                return Response()