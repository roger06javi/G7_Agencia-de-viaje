import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
    obtenerCategorias, 
    crearCategoria, 
    actualizarCategoria, 
    eliminarCategoria 
} from '../services/categoriaService';

function Categorias() {
    const navigate = useNavigate();
    const [user, setUser] = useState('');
    const [categorias, setCategorias] = useState([]);
    const [busqueda, setBusqueda] = useState('');
    const [loading, setLoading] = useState(false);
    const [errorMsg, setErrorMsg] = useState('');
    const [successMsg, setSuccessMsg] = useState('');

    // Estados para el formulario (Crear / Editar)
    const [showModal, setShowModal] = useState(false);
    const [editMode, setEditMode] = useState(false);
    const [selectedId, setSelectedId] = useState(null);
    const [nombreCat, setNombreCat] = useState('');
    const [descripcionCat, setDescripcionCat] = useState('');
    const [estadoCat, setEstadoCat] = useState(true);

    useEffect(() => {
        const token = localStorage.getItem('access');
        if (!token) {
            navigate('/');
        } else {
            const storedUser = localStorage.getItem('username');
            setUser(storedUser || 'Usuario');
            cargarCategorias();
        }
    }, [navigate]);

    const cargarCategorias = async () => {
        setLoading(true);
        setErrorMsg('');
        try {
            const data = await obtenerCategorias();
            setCategorias(data);
        } catch (error) {
            console.error('Error al cargar categorias:', error);
            setErrorMsg('No se pudieron cargar las categorías. Intente de nuevo.');
        } finally {
            setLoading(false);
        }
    };

    const limpiarFormulario = () => {
        setNombreCat('');
        setDescripcionCat('');
        setEstadoCat(true);
        setSelectedId(null);
        setEditMode(false);
    };

    const abrirCrearModal = () => {
        limpiarFormulario();
        setErrorMsg('');
        setShowModal(true);
    };

    const abrirEditarModal = (cat) => {
        setErrorMsg('');
        setSelectedId(cat.id);
        setNombreCat(cat.nombre_cat);
        setDescripcionCat(cat.descripcion_cat);
        setEstadoCat(cat.estado_cat);
        setEditMode(true);
        setShowModal(true);
    };

    const cerrarModal = () => {
        setShowModal(false);
        limpiarFormulario();
    };

    const guardarCategoria = async (e) => {
        e.preventDefault();
        setErrorMsg('');
        setSuccessMsg('');

        if (!nombreCat.trim()) {
            setErrorMsg('El nombre de la categoría es obligatorio.');
            return;
        }

        const data = {
            nombre_cat: nombreCat,
            descripcion_cat: descripcionCat,
            estado_cat: estadoCat
        };

        try {
            if (editMode) {
                await actualizarCategoria(selectedId, data);
                setSuccessMsg('Categoría actualizada con éxito.');
            } else {
                await crearCategoria(data);
                setSuccessMsg('Categoría creada con éxito.');
            }
            cerrarModal();
            cargarCategorias();
            // Desaparecer el mensaje de éxito después de 3 segundos
            setTimeout(() => setSuccessMsg(''), 3000);
        } catch (error) {
            console.error('Error al guardar categoria:', error);
            if (error.response && error.response.data) {
                // Mostrar primer error si viene del backend
                const backendErrors = Object.values(error.response.data).flat();
                setErrorMsg(backendErrors[0] || 'Error al guardar los datos.');
            } else {
                setErrorMsg('Ocurrió un error en el servidor.');
            }
        }
    };

    const handleEliminar = async (id, nombre) => {
        if (window.confirm(`¿Está seguro de que desea eliminar la categoría "${nombre}"?`)) {
            setErrorMsg('');
            setSuccessMsg('');
            try {
                await eliminarCategoria(id);
                setSuccessMsg('Categoría eliminada con éxito.');
                cargarCategorias();
                setTimeout(() => setSuccessMsg(''), 3000);
            } catch (error) {
                console.error('Error al eliminar categoria:', error);
                setErrorMsg('No se pudo eliminar la categoría. Puede tener dependencias.');
            }
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('access');
        localStorage.removeItem('refresh');
        localStorage.removeItem('username');
        navigate('/');
    };

    // Filtrar categorias en tiempo real por búsqueda
    const categoriasFiltradas = categorias.filter(cat => 
        cat.nombre_cat.toLowerCase().includes(busqueda.toLowerCase()) ||
        cat.descripcion_cat.toLowerCase().includes(busqueda.toLowerCase())
    );

    return (
        <div className="dashboard-container">
            <header className="dashboard-header">
                <div className="header-brand" onClick={() => navigate('/dashboard')} style={{ cursor: 'pointer' }}>
                    <h2>🚀 Django REST Portal</h2>
                </div>
                <div className="user-profile">
                    <span className="user-badge" onClick={() => navigate('/dashboard')} style={{ cursor: 'pointer' }}>
                        🏠 Inicio
                    </span>
                    <span className="user-badge">👤 {user}</span>
                    <button onClick={handleLogout} className="btn-secondary">
                        Cerrar Sesión
                    </button>
                </div>
            </header>

            <main className="dashboard-content">
                <section className="welcome-banner" style={{ padding: '28px 40px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
                        <div>
                            <h1 style={{ fontSize: '28px', margin: '0 0 8px 0' }}>Gestión de Categorías 📁</h1>
                            <p>Crea, edita, elimina y visualiza las categorías de productos de la plataforma.</p>
                        </div>
                        <button onClick={abrirCrearModal} className="btn-primary" style={{ marginTop: 0, padding: '12px 24px' }}>
                            ➕ Nueva Categoría
                        </button>
                    </div>
                </section>

                {successMsg && <div className="success-banner">{successMsg}</div>}
                {errorMsg && <div className="error-banner">{errorMsg}</div>}

                {/* Filtros de búsqueda */}
                <div className="search-bar-container">
                    <input 
                        type="text" 
                        placeholder="🔍 Buscar categoría por nombre o descripción..." 
                        value={busqueda} 
                        onChange={(e) => setBusqueda(e.target.value)}
                        className="search-input"
                    />
                </div>

                {/* Tabla de Categorías */}
                <div className="table-card">
                    {loading ? (
                        <div className="loading-spinner">Cargando categorías... ⚡</div>
                    ) : categoriasFiltradas.length > 0 ? (
                        <div className="table-responsive">
                            <table className="custom-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Nombre</th>
                                        <th>Descripción</th>
                                        <th>Estado</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {categoriasFiltradas.map((cat) => (
                                        <tr key={cat.id}>
                                            <td><span className="badge-id">#{cat.id}</span></td>
                                            <td className="td-name">{cat.nombre_cat}</td>
                                            <td className="td-desc">{cat.descripcion_cat || <span className="no-data">Sin descripción</span>}</td>
                                            <td>
                                                <span className={`status-pill ${cat.estado_cat ? 'active' : 'inactive'}`}>
                                                    {cat.estado_cat ? '🟢 Activo' : '🔴 Inactivo'}
                                                </span>
                                            </td>
                                            <td>
                                                <div className="action-buttons">
                                                    <button 
                                                        onClick={() => abrirEditarModal(cat)} 
                                                        className="btn-action edit"
                                                        title="Editar Categoría"
                                                    >
                                                        ✏️ Editar
                                                    </button>
                                                    <button 
                                                        onClick={() => handleEliminar(cat.id, cat.nombre_cat)} 
                                                        className="btn-action delete"
                                                        title="Eliminar Categoría"
                                                    >
                                                        🗑️ Eliminar
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    ) : (
                        <div className="empty-state">
                            <p>No se encontraron categorías. {busqueda ? 'Intente con otra búsqueda.' : 'Cree una nueva categoría para comenzar.'}</p>
                        </div>
                    )}
                </div>
            </main>

            {/* Modal de Crear / Editar Categoría */}
            {showModal && (
                <div className="modal-overlay">
                    <div className="modal-card">
                        <div className="modal-header">
                            <h3>{editMode ? '✏️ Editar Categoría' : '➕ Nueva Categoría'}</h3>
                            <button onClick={cerrarModal} className="close-btn">&times;</button>
                        </div>
                        <form onSubmit={guardarCategoria} className="login-form">
                            <div className="input-group">
                                <label htmlFor="nombre_cat">Nombre de la Categoría</label>
                                <input 
                                    id="nombre_cat"
                                    type="text" 
                                    placeholder="Ej. Electrónica" 
                                    value={nombreCat} 
                                    onChange={(e) => setNombreCat(e.target.value)}
                                    maxLength={40}
                                    required
                                />
                            </div>

                            <div className="input-group">
                                <label htmlFor="descripcion_cat">Descripción</label>
                                <textarea 
                                    id="descripcion_cat"
                                    placeholder="Breve descripción de la categoría (máx 200 caracteres)..." 
                                    value={descripcionCat} 
                                    onChange={(e) => setDescripcionCat(e.target.value)}
                                    maxLength={200}
                                    rows="4"
                                    className="custom-textarea"
                                />
                            </div>

                            <div className="input-group checkbox-group">
                                <label className="switch-container">
                                    <input 
                                        type="checkbox" 
                                        checked={estadoCat} 
                                        onChange={(e) => setEstadoCat(e.target.checked)}
                                    />
                                    <span className="switch-label">Categoría Activa</span>
                                </label>
                            </div>

                            <div className="modal-actions">
                                <button type="button" onClick={cerrarModal} className="btn-secondary" style={{ margin: 0 }}>
                                    Cancelar
                                </button>
                                <button type="submit" className="btn-primary" style={{ margin: 0 }}>
                                    {editMode ? 'Actualizar' : 'Guardar'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

export default Categorias;
