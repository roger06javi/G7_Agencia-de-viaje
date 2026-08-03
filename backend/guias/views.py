from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import GuiaTuristico
from .serializers import GuiaTuristicoSerializer

class GuiaTuristicoViewSet(viewsets.ModelViewSet):
    queryset = GuiaTuristico.objects.all().order_by('-id')
    serializer_class = GuiaTuristicoSerializer
    permission_classes = [IsAuthenticated]
