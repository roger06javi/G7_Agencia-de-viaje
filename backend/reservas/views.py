# Crear vista de reserva, con permisos de autenticación y ordenamiento por id descendente.
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Reserva
from .serializers import ReservaSerializer
# Creamos la vista de reserva asa
class ReservaViewSet(viewsets.ModelViewSet):
    queryset = Reserva.objects.all().order_by('-id')
    serializer_class = ReservaSerializer
    permission_classes = [IsAuthenticated]
