import api from './api';

export const obtenerProductos = async () => {
    const respuesta = await api.get('productos/productos/');
    return respuesta.data;
};

export const crearProducto = async (data) => {
    const respuesta = await api.post('productos/productos/', data);
    return respuesta.data;
};

export const actualizarProducto = async (id, data) => {
    const respuesta = await api.put(`productos/productos/${id}/`, data);
    return respuesta.data;
};

export const eliminarProducto = async (id) => {
    await api.delete(`productos/productos/${id}/`);
};
