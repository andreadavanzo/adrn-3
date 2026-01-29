from django.shortcuts import render
from .models import Greeting

def hello(request):
    context = {'greeting': Greeting.fetch()}
    return render(request, 'index.html', context)
