from student.models import Student
from warden.models import Warden
from django.shortcuts import get_object_or_404
from home.models import Outpass,OPRecord,OTP
from tutor.models import Tutor
from django.core.exceptions import PermissionDenied
from security.models import Security
from django.http import Http404
import json
import random
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

def get_otp():
    otp = str(random.randrange(10000,99999))
    otps= [otp.otp for otp in OTP.objects.all()]
    while otp in otps:
        otp = str(random.randrange(1000,9999))
    return otp

class LoginView(APIView):
    def post(self, request):
        try:
            if(request.POST.get('role') == "student"): 
                user = Student.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
            elif(request.POST.get('role') == "warden"): 
                user = Warden.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
            elif(request.POST.get('role') == "tutor"):
                user = Tutor.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
            elif(request.POST.get('role') == "security"): 
                user = Security.objects.get(
                user=User.objects.get(email=request.POST.get('email'))
                ).user
            
        except:
            raise SuspiciousOperation("wrong credentials")
        else:
            user = authenticate(request, 
            username=user.username, 
            password=request.POST.get('password')
            )
            if user is None:
                raise SuspiciousOperation("wrong credentials")
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
                otp = None
                if not outpass.otp_set.first() == None:
                    otp = outpass.otp_set.first().otp
                return Response({'outpass':{
                    'pk':outpass.pk,
                    'req-time': outpass.req_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'dep-time': outpass.dep_date.astimezone(tz).strftime(r'%d/%m/%Y, %I:%M %p'),
                    'req-days': outpass.req_days,
                    'reason': outpass.reason.replace('\n','').replace('\r',''),
                    'tutor': outpass.tutor_status,
                    'warden': outpass.warden_status,
                    'security': outpass.security_status,
                    'otp':otp
                }})
            return Response({'outpass':''})

    def post(self, request):
        try:
            student = request.user.student
        except:
            raise SuspiciousOperation
        else:
            if student.outpass_set.count() == 0:
                warden = Warden.objects.first()
                date = request.POST.get('dep-date').replace('/', ' ')
                tz = pytz.timezone('Asia/Kolkata')
                date = tz.localize(dt=datetime.datetime.strptime(date, r'%d %m %Y %I:%M %p'))
                outpass = Outpass(
                student = request.user.student,
                tutor_status = 'pending',
                req_warden = warden,
                warden_status = 'pending',
                security_status = 'pending',
                reason = request.POST.get('reason').rstrip().strip().lstrip(),
                dep_date = date,
                req_days = request.POST.get('req-days')
                )
                outpass.save()
                return Response()
            else:
                raise PermissionDenied

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
                elif not outpass.tutor_status == 'accepted' and not outpass.tutor_status == 'accepted':
                    raise PermissionDenied
                elif outpass.otp_set.count() >= 1:
                    raise PermissionDenied
                else:
                    otp = OTP(
                    otp = get_otp(),
                    outpass = outpass
                    )
                    otp.save()
                    return Response()
                    
            elif json.loads(request.body)['task'] == 'delete':   
                if outpass.student.pk == request.user.student.pk:
                    outpass.delete()
                    return Response()
                else:
                    raise PermissionDenied

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
                [student.outpass_set.first() for student in request.user.tutor.student_set.all() if student.outpass_set.first() and student.outpass_set.first().tutor_status == 'pending'],
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
            outpass = get_object_or_404(Outpass,pk=json.loads(request.body)['pk'])
            if request.user.tutor in outpass.student.tutors.all():
                if(json.loads(request.body)['task'] == 'accept'):
                    outpass.tutor_status = 'accepted'
                    outpass.accepted_tutor = request.user.tutor
                    outpass.save()
                    return Response()
                elif(json.loads(request.body)['task'] == 'reject'):
                    outpass.tutor_status = 'rejected'
                    outpass.accepted_tutor = request.user.tutor
                    outpass.save()
                    return Response()
            else:
                raise PermissionDenied

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
            all_outpass = [outpass for outpass in request.user.warden.outpass_set.all().order_by('id') if outpass.tutor_status == 'accepted' and outpass.warden_status == 'pending']
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
            if request.user.warden.pk == outpass.req_warden.pk:
                if(json.loads(request.body)['task'] == 'accept'):
                    outpass.warden_status = 'accepted'
                    outpass.save()
                    return Response()
                elif(json.loads(request.body)['task'] == 'reject'):
                    outpass.warden_status = 'rejected'
                    outpass.save()
                    return Response()
            else:
                raise PermissionDenied

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
                    otp.outpass.security_status = 'accepted'
                    otp.outpass.accepted_security = request.user.security
                    otp.outpass.save()
                    otp.outpass.otp_set.first().delete()
                    return Response()
                elif task == 'reject':
                    otp.outpass.security_status = 'rejected'
                    otp.outpass.accepted_security = request.user.security
                    otp.outpass.save()
                    otp.outpass.otp_set.first.delete()
                    return Response()
                else:
                    raise SuspiciousOperation