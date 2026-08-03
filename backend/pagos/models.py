from django.db import models
from reservas.models import Reserva

class Pago(models.Model):
    fecha_pago = models.DateField()
    monto = models.DecimalField(max_digits=10, decimal_places=2)
    metodo_pago = models.CharField(max_length=30)
    reserva = models.ForeignKey(Reserva, on_delete=models.CASCADE, related_name='pagos')

    def __str__(self):
        return f"Pago #{self.id} (${self.monto}) - Reserva #{self.reserva.id}"
