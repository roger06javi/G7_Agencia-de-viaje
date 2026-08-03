from django.db import models
from clientes.models import Cliente
from paquetes.models import PaqueteTuristico

class Reserva(models.Model):
    fecha_reserva = models.DateField()
    cantidad_personas = models.IntegerField()
    estado = models.CharField(max_length=30, default='Pendiente')
    cliente = models.ForeignKey(Cliente, on_delete=models.CASCADE, related_name='reservas')
    paquete = models.ForeignKey(PaqueteTuristico, on_delete=models.CASCADE, related_name='reservas')

    def __str__(self):
        return f"Reserva #{self.id} - {self.cliente} ({self.paquete})"
