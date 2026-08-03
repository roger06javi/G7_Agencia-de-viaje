from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DestinoViewSet

router = DefaultRouter()
router.register(r'', DestinoViewSet, basename='destino')

urlpatterns = [
    path('', include(router.urls)),
]
