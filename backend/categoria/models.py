from django.db import models

# Create your models here.
class Categoria(models.Model):
    nombre_cat = models.CharField(max_length=40)
    descripcion_cat = models.TextField(max_length=200)
    estado_cat = models.BooleanField(default=True)

    def __str__(self):
        return self.nombre_cat