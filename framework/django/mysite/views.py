from django.shortcuts import render

def hello(request):
    context = {'greeting': 'hello world'}
    return render(request, 'index.html', context)
