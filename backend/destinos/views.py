from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from .models import Destino
from .serializers import DestinoSerializer

class DestinoViewSet(viewsets.ModelViewSet):
    queryset = Destino.objects.all().order_by('-id')
    serializer_class = DestinoSerializer
    permission_classes = [AllowAny]
