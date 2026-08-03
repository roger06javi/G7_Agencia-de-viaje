from django.db import models

class Destino(models.Model):
    nombre_destino = models.CharField(max_length=100)
    pais = models.CharField(max_length=50)
    ciudad = models.CharField(max_length=50)
    descripcion = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.nombre_destino} ({self.ciudad}, {self.pais})"
