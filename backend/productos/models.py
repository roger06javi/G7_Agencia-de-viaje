# CREAR MODELO DE PRODUCTO, CON FK PARA MEJOR RELACIÓN CON CATEGORÍA.
from django.db import models
from categoria.models import Categoria


class Producto(models.Model):
    nombre_prod = models.CharField(max_length=150)
    descripcion_prod = models.TextField(max_length=500, blank=True, null=True)
    precio = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.PositiveIntegerField(default=0)
    estado_prod = models.BooleanField(default=True)
    categoria = models.ForeignKey(
        Categoria,
        on_delete=models.CASCADE,
        related_name='productos'
    )

    def __str__(self):
        return self.nombre_prod
