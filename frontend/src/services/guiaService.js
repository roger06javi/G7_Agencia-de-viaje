import api from './api';

// Obtener todos los guías
export const obtenerGuias = async () => {
    const res = await api.get('guias/');
    return res.data;
};

// Crear un nuevo guía
export const crearGuia = async (data) => {
    const res = await api.post('guias/', data);
    return res.data;
};

// Actualizar guía existente
export const actualizarGuia = async (id, data) => {
    const res = await api.put(`guias/${id}/`, data);
    return res.data;
};

// Eliminar guía
export const eliminarGuia = async (id) => {
    await api.delete(`guias/${id}/`);
};
