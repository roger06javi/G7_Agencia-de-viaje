from django.db import models
from destinos.models import Destino

class PaqueteTuristico(models.Model):
    nombre_paquete = models.CharField(max_length=100)
    precio = models.DecimalField(max_digits=10, decimal_places=2)
    duracion_dias = models.IntegerField()
    destino = models.ForeignKey(Destino, on_delete=models.CASCADE, related_name='paquetes')

    def __str__(self):
        return self.nombre_paquete
