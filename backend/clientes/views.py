from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from .models import Cliente
from .serializers import ClienteSerializer


class ClienteViewSet(viewsets.ModelViewSet):
    queryset = Cliente.objects.all().order_by('-id')
    serializer_class = ClienteSerializer
    permission_classes = [AllowAny]