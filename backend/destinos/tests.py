from django.test import TestCase
from rest_framework.test import APIClient


class DestinoAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_list_and_create_destinos_without_auth(self):
        response = self.client.get('/api/destinos/')
        self.assertEqual(response.status_code, 200)

        response = self.client.post('/api/destinos/', {
            'nombre_destino': 'Cartagena Colonial',
            'pais': 'Colombia',
            'ciudad': 'Cartagena',
            'descripcion': 'Ciudad histórica',
        }, format='json')

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['nombre_destino'], 'Cartagena Colonial')
