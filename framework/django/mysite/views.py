from django.http import HttpResponse
from .models import Greeting

def hello(request):
    message = Greeting.fetch()
    return HttpResponse(message, content_type="text/plain")
