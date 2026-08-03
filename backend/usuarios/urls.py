from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from .views import UserViewSet

router = DefaultRouter()
router.register(r'usuarios', UserViewSet, basename='usuario')

urlpatterns = [
    path('', include(router.urls)),
    path('login/', TokenObtainPairView.as_view(), name='token'),
    path('refresh/', TokenRefreshView.as_view(), name='refresh'),
]