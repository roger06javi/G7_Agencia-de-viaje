import api from './api';

export const obtenerCategorias = async () => {
    const respuesta = await api.get('categoria/categorias/');
    return respuesta.data;
};

export const crearCategoria = async (data) => {
    const respuesta = await api.post('categoria/categorias/', data);
    return respuesta.data;
};

export const actualizarCategoria = async (id, data) => {
    const respuesta = await api.put(`categoria/categorias/${id}/`, data);
    return respuesta.data;
};

export const eliminarCategoria = async (id) => {
    const respuesta = await api.delete(`categoria/categorias/${id}/`);
    return respuesta.data;
};
