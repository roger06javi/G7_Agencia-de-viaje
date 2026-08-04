import api from './api';

// Obtener todos los pagos
export const obtenerPagos = async () => {
    const res = await api.get('pagos/');
    return res.data;
};

// Crear un nuevo pago
export const crearPago = async (data) => {
    const res = await api.post('pagos/', data);
    return res.data;
};

// Actualizar pago existente
export const actualizarPago = async (id, data) => {
    const res = await api.put(`pagos/${id}/`, data);
    return res.data;
};

// Eliminar pago
export const eliminarPago = async (id) => {
    await api.delete(`pagos/${id}/`);
};
