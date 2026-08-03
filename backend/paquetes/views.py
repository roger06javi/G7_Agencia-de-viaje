from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import PaqueteTuristico
from .serializers import PaqueteTuristicoSerializer

class PaqueteTuristicoViewSet(viewsets.ModelViewSet):
    queryset = PaqueteTuristico.objects.all().order_by('-id')
    serializer_class = PaqueteTuristicoSerializer
    permission_classes = [IsAuthenticated]
