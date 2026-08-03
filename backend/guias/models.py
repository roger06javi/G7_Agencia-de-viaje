from django.db import models
from destinos.models import Destino

class GuiaTuristico(models.Model):
    nombre = models.CharField(max_length=100)
    telefono = models.CharField(max_length=20)
    experiencia = models.CharField(max_length=100)
    destino = models.ForeignKey(Destino, on_delete=models.CASCADE, related_name='guias')

    def __str__(self):
        return f"{self.nombre} ({self.destino.nombre_destino if self.destino else 'Sin destino'})"
