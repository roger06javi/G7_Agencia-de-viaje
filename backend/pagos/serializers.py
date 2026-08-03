from rest_framework import serializers
from .models import Pago

class PagoSerializer(serializers.ModelSerializer):
    reserva_info = serializers.ReadOnlyField(source='reserva.__str__')

    class Meta:
        model = Pago
        fields = '__all__'
