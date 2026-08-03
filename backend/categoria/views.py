from django.shortcuts import render
from .models import Categoria
from rest_framework import viewsets
from .serializers import CategoriaSerializer
from rest_framework.permissions import IsAuthenticated

class CategoriaViewSet(viewsets.ModelViewSet):
    queryset = Categoria.objects.all().order_by('-id')
    serializer_class = CategoriaSerializer
    permission_classes = [IsAuthenticated]

    