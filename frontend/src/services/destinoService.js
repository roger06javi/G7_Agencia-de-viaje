import api from './api';

// Obtener todos los destinos
export const obtenerDestinos = async () => {
    const res = await api.get('destinos/');
    return res.data;
};

// Crear un nuevo destino
export const crearDestino = async (data) => {
    const res = await api.post('destinos/', data);
    return res.data;
};

// Actualizar destino existente
export const actualizarDestino = async (id, data) => {
    const res = await api.put(`destinos/${id}/`, data);
    return res.data;
};

// Eliminar destino
export const eliminarDestino = async (id) => {
    await api.delete(`destinos/${id}/`);
};
