import api from './api';

// Obtener todos los paquetes
export const obtenerPaquetes = async () => {
    const res = await api.get('paquetes/');
    return res.data;
};

// Crear un nuevo paquete
export const crearPaquete = async (data) => {
    const res = await api.post('paquetes/', data);
    return res.data;
};

// Actualizar paquete existente
export const actualizarPaquete = async (id, data) => {
    const res = await api.put(`paquetes/${id}/`, data);
    return res.data;
};

// Eliminar paquete
export const eliminarPaquete = async (id) => {
    await api.delete(`paquetes/${id}/`);
};
