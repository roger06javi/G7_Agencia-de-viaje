import { useEffect, useState, useCallback } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { obtenerClientes, crearCliente, actualizarCliente, eliminarCliente } from '../services/clienteService';
import { obtenerDestinos, crearDestino, actualizarDestino, eliminarDestino } from '../services/destinoService';
import { obtenerPaquetes, crearPaquete, actualizarPaquete, eliminarPaquete } from '../services/paqueteService';
import { obtenerReservas, crearReserva, actualizarReserva, eliminarReserva } from '../services/reservaService';
import { obtenerPagos, crearPago, actualizarPago, eliminarPago } from '../services/pagoService';
import { obtenerGuias, crearGuia, actualizarGuia, eliminarGuia } from '../services/guiaService';

const TABS = [
    { key: 'inicio',    icon: '🏠', label: 'Inicio' },
    { key: 'clientes',  icon: '👥', label: 'Clientes' },
    { key: 'destinos',  icon: '📍', label: 'Destinos' },
    { key: 'paquetes',  icon: '🎒', label: 'Paquetes' },
    { key: 'reservas',  icon: '📅', label: 'Reservas' },
    { key: 'pagos',     icon: '💳', label: 'Pagos' },
    { key: 'guias',     icon: '👨‍💼', label: 'Guías' },
];

function useMsg() {
    const [err, setErr] = useState('');
    const [ok,  setOk]  = useState('');
    const flash = (type, msg) => {
        if (type === 'ok')  { setOk(msg);  setTimeout(() => setOk(''),  3500); }
        else                { setErr(msg); setTimeout(() => setErr(''), 5000); }
    };
    const clear = () => { setErr(''); setOk(''); };
    return { err, ok, flash, clear };
}

export default function Dashboard() {
    const navigate = useNavigate();
    const [searchParams, setSearchParams] = useSearchParams();
    const [user, setUser]           = useState('');
    const [sidebarOpen, setSidebarOpen] = useState(true);
    const currentTab = searchParams.get('tab') || 'inicio';

    const [clientes,  setClientes]  = useState([]);
    const [destinos,  setDestinos]  = useState([]);
    const [paquetes,  setPaquetes]  = useState([]);
    const [reservas,  setReservas]  = useState([]);
    const [pagos,     setPagos]     = useState([]);
    const [guias,     setGuias]     = useState([]);
    const [loading,   setLoading]   = useState(false);
    const { err, ok, flash, clear } = useMsg();

    useEffect(() => {
        const token = localStorage.getItem('access');
        if (!token) { navigate('/'); return; }
        setUser(localStorage.getItem('username') || 'Usuario');
    }, [navigate]);

    const cargar = useCallback(async () => {
        setLoading(true);
        try {
            const [cl, de, pa, re, pg, gu] = await Promise.all([
                obtenerClientes().catch(() => []),
                obtenerDestinos().catch(() => []),
                obtenerPaquetes().catch(() => []),
                obtenerReservas().catch(() => []),
                obtenerPagos().catch(() => []),
                obtenerGuias().catch(() => []),
            ]);
            setClientes(cl); setDestinos(de); setPaquetes(pa);
            setReservas(re); setPagos(pg);    setGuias(gu);
        } catch { flash('err', 'Error al cargar datos.'); }
        finally { setLoading(false); }
    }, []);

    useEffect(() => { cargar(); }, [currentTab, cargar]);

    const switchTab = (key) => {
        clear();
        key === 'inicio' ? setSearchParams({}) : setSearchParams({ tab: key });
    };

    const handleLogout = () => { localStorage.clear(); navigate('/'); };

    return (
        <div className="app-shell">
            <div className={`sidebar-overlay ${sidebarOpen ? 'active' : ''}`} onClick={() => setSidebarOpen(false)}></div>
            <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
                <div className="sidebar-brand">
                    <span className="brand-icon">✈️</span>
                    <span className="brand-text">Agencia Viajes</span>
                </div>
                <nav className="sidebar-nav">
                    {TABS.map(t => (
                        <button key={t.key} className={`nav-item ${currentTab === t.key ? 'active' : ''}`} onClick={() => { switchTab(t.key); setSidebarOpen(false); }} title={t.label}>
                            <span className="nav-icon">{t.icon}</span>
                            <span className="nav-label">{t.label}</span>
                        </button>
                    ))}
                </nav>
                <div className="sidebar-footer">
                    <span className="sidebar-user">👤 {user}</span>
                    <button className="nav-item logout-btn" onClick={handleLogout} title="Salir">
                        <span className="nav-icon">🚪</span>
                        <span className="nav-label">Cerrar Sesión</span>
                    </button>
                </div>
            </aside>

            <div className="main-area">
                <header className="topbar">
                    <button className="toggle-btn" onClick={() => setSidebarOpen(p => !p)}>☰</button>
                    <h2 className="topbar-title">
                        {TABS.find(t => t.key === currentTab)?.icon}{' '}
                        {TABS.find(t => t.key === currentTab)?.label}
                    </h2>
                    <div className="topbar-right">
                        <span className="topbar-user">👤 {user}</span>
                    </div>
                </header>

                <main className="page-content">
                    {ok  && <div className="banner success"><span className="banner-icon">✅</span>{ok}</div>}
                    {err && <div className="banner error"><span className="banner-icon">❌</span>{err}</div>}

                    {currentTab === 'inicio'   && <TabInicio clientes={clientes} destinos={destinos} paquetes={paquetes} reservas={reservas} pagos={pagos} guias={guias} switchTab={switchTab} />}
                    {currentTab === 'clientes' && <TabClientes  clientes={clientes}  reload={cargar} flash={flash} loading={loading} />}
                    {currentTab === 'destinos' && <TabDestinos  destinos={destinos}  reload={cargar} flash={flash} loading={loading} />}
                    {currentTab === 'paquetes' && <TabPaquetes  paquetes={paquetes}  destinos={destinos} reload={cargar} flash={flash} loading={loading} />}
                    {currentTab === 'reservas' && <TabReservas  reservas={reservas}  clientes={clientes} paquetes={paquetes} reload={cargar} flash={flash} loading={loading} />}
                    {currentTab === 'pagos'    && <TabPagos     pagos={pagos}        reservas={reservas} reload={cargar} flash={flash} loading={loading} />}
                    {currentTab === 'guias'    && <TabGuias     guias={guias}        destinos={destinos} reload={cargar} flash={flash} loading={loading} />}
                </main>
            </div>
        </div>
    );
}

/* ── TAB INICIO ─────────────────────────────────────────── */
function TabInicio({ clientes, destinos, paquetes, reservas, pagos, guias, switchTab }) {
    const stats = [
        { label: 'Clientes',  value: clientes.length,  icon: '👥', color: '#34d399', tab: 'clientes' },
        { label: 'Destinos',  value: destinos.length,  icon: '📍', color: '#818cf8', tab: 'destinos' },
        { label: 'Paquetes',  value: paquetes.length,  icon: '🎒', color: '#fb923c', tab: 'paquetes' },
        { label: 'Reservas',  value: reservas.length,  icon: '📅', color: '#38bdf8', tab: 'reservas' },
        { label: 'Pagos',     value: pagos.length,     icon: '💳', color: '#a78bfa', tab: 'pagos'    },
        { label: 'Guías',     value: guias.length,     icon: '👨‍💼', color: '#f472b6', tab: 'guias'    },
    ];
    const accesos = [
        { tab:'clientes', icon:'👥', title:'Clientes',          desc:'Gestiona el registro de clientes.' },
        { tab:'destinos', icon:'📍', title:'Destinos',           desc:'Administra los destinos turísticos.' },
        { tab:'paquetes', icon:'🎒', title:'Paquetes Turísticos',desc:'Paquetes vinculados a destinos.' },
        { tab:'reservas', icon:'📅', title:'Reservas',           desc:'Control de reservas y estados.' },
        { tab:'pagos',    icon:'💳', title:'Pagos',              desc:'Registro de pagos por reserva.' },
        { tab:'guias',    icon:'👨‍💼', title:'Guías',              desc:'Guías turísticos por destino.' },
    ];
    return (
        <div>
            <div className="page-header">
                <div>
                    <h1>Panel de Control ✈️</h1>
                    <p className="page-sub">Resumen general de la agencia de viajes.</p>
                </div>
            </div>
            <div className="stats-grid">
                {stats.map(s => (
                    <div key={s.label} className="stat-card" style={{'--accent': s.color}} onClick={() => switchTab(s.tab)}>
                        <div className="stat-icon">{s.icon}</div>
                        <div><div className="stat-value">{s.value}</div><div className="stat-label">{s.label}</div></div>
                    </div>
                ))}
            </div>
            <div className="quick-grid">
                {accesos.map(a => (
                    <div key={a.tab} className="quick-card" onClick={() => switchTab(a.tab)}>
                        <span className="quick-icon">{a.icon}</span>
                        <div><h3>{a.title}</h3><p>{a.desc}</p></div>
                        <span className="quick-arrow">→</span>
                    </div>
                ))}
            </div>
        </div>
    );
}

/* ── HELPERS COMPARTIDOS ────────────────────────────────── */
function Field({ label, required, children }) {
    return (
        <div className="input-group">
            <label>{label}{required && <span className="required"> *</span>}</label>
            {children}
        </div>
    );
}
function Spinner() { return <div className="loading-spinner">Cargando... ⚡</div>; }
function Empty({ texto }) { return <div className="empty-state"><p>🗂️ {texto}</p></div>; }

/* ── TAB CLIENTES ───────────────────────────────────────── */
function TabClientes({ clientes, reload, flash, loading }) {
    const [busq, setBusq]       = useState('');
    const [modal, setModal]     = useState(false);
    const [edit, setEdit]       = useState(false);
    const [selId, setSelId]     = useState(null);
    const [nombre, setNombre]   = useState('');
    const [apellido, setApellido] = useState('');
    const [cedula, setCedula]   = useState('');
    const [telefono, setTelefono] = useState('');
    const [correo, setCorreo]   = useState('');

    const limpiar = () => { setNombre(''); setApellido(''); setCedula(''); setTelefono(''); setCorreo(''); setSelId(null); setEdit(false); };
    const abrir   = () => { limpiar(); setModal(true); };
    const editarM = (c) => { setSelId(c.id); setNombre(c.nombre); setApellido(c.apellido); setCedula(c.cedula); setTelefono(c.telefono||''); setCorreo(c.correo); setEdit(true); setModal(true); };
    const cerrar  = () => { setModal(false); limpiar(); };

    const guardar = async (e) => {
        e.preventDefault();
        const data = { nombre, apellido, cedula, telefono, correo };
        try {
            if (edit) { await actualizarCliente(selId, data); flash('ok', 'Cliente actualizado ✓'); }
            else       { await crearCliente(data);             flash('ok', 'Cliente creado ✓'); }
            cerrar(); reload();
        } catch (err) {
            const msg = err.response?.data ? Object.values(err.response.data).flat()[0] : 'Error al guardar.';
            flash('err', String(msg));
        }
    };

    const eliminar = async (id, nombre) => {
        if (!window.confirm(`¿Eliminar al cliente "${nombre}"?`)) return;
        try { await eliminarCliente(id); flash('ok', 'Cliente eliminado ✓'); reload(); }
        catch { flash('err', 'No se pudo eliminar el cliente.'); }
    };

    const filtrados = clientes.filter(c =>
        `${c.nombre} ${c.apellido} ${c.cedula} ${c.correo}`.toLowerCase().includes(busq.toLowerCase())
    );

    return (
        <div>
            <div className="page-header">
                <div><h1>Clientes 🧑‍🤝‍🧑</h1><p className="page-sub">Gestión de clientes registrados.</p></div>
                <button className="btn-primary" onClick={abrir}>➕ Nuevo Cliente</button>
            </div>
            <input className="search-input" placeholder="� Buscar por nombre, cédula o correo…" value={busq} onChange={e => setBusq(e.target.value)} />
            <div className="table-card">
                {loading ? <Spinner /> : filtrados.length === 0 ? <Empty texto={busq ? 'Sin resultados.' : 'No hay clientes aún.'} /> : (
                    <div className="table-responsive">
                        <table className="custom-table">
                            <thead><tr><th>ID</th><th>Nombre</th><th>Cédula</th><th>Teléfono</th><th>Correo</th><th>Acciones</th></tr></thead>
                            <tbody>
                                {filtrados.map(c => (
                                    <tr key={c.id}>
                                        <td><span className="badge-id">#{c.id}</span></td>
                                        <td className="td-name">{c.nombre} {c.apellido}</td>
                                        <td><span className="badge-blue">{c.cedula}</span></td>
                                        <td>{c.telefono || <span className="no-data">—</span>}</td>
                                        <td className="td-desc">{c.correo}</td>
                                        <td><div className="action-buttons">
                                            <button className="btn-action edit" onClick={() => editarM(c)}>📝 Editar</button>
                                            <button className="btn-action delete" onClick={() => eliminar(c.id, `${c.nombre} ${c.apellido}`)}>🗑️ Eliminar</button>
                                        </div></td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
            {modal && (
                <div className="modal-overlay">
                    <div className="modal-card modal-wide">
                        <div className="modal-header">
                            <h3>{edit ? '📝 Editar Cliente' : '➕ Nuevo Cliente'}</h3>
                            <button className="close-btn" onClick={cerrar}>&times;</button>
                        </div>
                        <form onSubmit={guardar} className="modal-form">
                            <div className="form-row">
                                <Field label="Nombre" required><input type="text" value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Nombre" required /></Field>
                                <Field label="Apellido" required><input type="text" value={apellido} onChange={e=>setApellido(e.target.value)} placeholder="Apellido" required /></Field>
                            </div>
                            <div className="form-row">
                                <Field label="Cédula" required><input type="text" value={cedula} onChange={e=>setCedula(e.target.value)} placeholder="123456789" required /></Field>
                                <Field label="Teléfono"><input type="text" value={telefono} onChange={e=>setTelefono(e.target.value)} placeholder="+57 300 000 0000" /></Field>
                            </div>
                            <Field label="Correo Electrónico" required><input type="email" value={correo} onChange={e=>setCorreo(e.target.value)} placeholder="correo@ejemplo.com" required /></Field>
                            <div className="modal-actions">
                                <button type="button" className="btn-secondary" onClick={cerrar}>❌ Cancelar</button>
                                <button type="submit" className="btn-primary">{edit ? '✅ Actualizar' : '💾 Guardar'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

/* ── TAB DESTINOS ───────────────────────────────────────── */
function TabDestinos({ destinos, reload, flash, loading }) {
    const [busq, setBusq]           = useState('');
    const [modal, setModal]         = useState(false);
    const [edit, setEdit]           = useState(false);
    const [selId, setSelId]         = useState(null);
    const [nombre, setNombre]       = useState('');
    const [pais, setPais]           = useState('');
    const [ciudad, setCiudad]       = useState('');
    const [descripcion, setDescripcion] = useState('');

    const limpiar = () => { setNombre(''); setPais(''); setCiudad(''); setDescripcion(''); setSelId(null); setEdit(false); };
    const abrir   = () => { limpiar(); setModal(true); };
    const editarM = (d) => { setSelId(d.id); setNombre(d.nombre_destino); setPais(d.pais); setCiudad(d.ciudad); setDescripcion(d.descripcion||''); setEdit(true); setModal(true); };
    const cerrar  = () => { setModal(false); limpiar(); };

    const guardar = async (e) => {
        e.preventDefault();
        const data = { nombre_destino: nombre, pais, ciudad, descripcion };
        try {
            if (edit) { await actualizarDestino(selId, data); flash('ok', 'Destino actualizado ✓'); }
            else       { await crearDestino(data);             flash('ok', 'Destino creado ✓'); }
            cerrar(); reload();
        } catch (err) {
            const msg = err.response?.data ? Object.values(err.response.data).flat()[0] : 'Error al guardar.';
            flash('err', String(msg));
        }
    };

    const eliminar = async (id, nombre) => {
        if (!window.confirm(`¿Eliminar el destino "${nombre}"? Se eliminarán sus paquetes y guías.`)) return;
        try { await eliminarDestino(id); flash('ok', 'Destino eliminado ✓'); reload(); }
        catch { flash('err', 'No se pudo eliminar el destino.'); }
    };

    const filtrados = destinos.filter(d =>
        `${d.nombre_destino} ${d.ciudad} ${d.pais}`.toLowerCase().includes(busq.toLowerCase())
    );

    return (
        <div>
            <div className="page-header">
                <div><h1>Destinos 🌍</h1><p className="page-sub">Administra los destinos turísticos disponibles.</p></div>
                <button className="btn-primary" onClick={abrir}>➕ Nuevo Destino</button>
            </div>
            <input className="search-input" placeholder="🔍 Buscar por nombre, ciudad o país…" value={busq} onChange={e => setBusq(e.target.value)} />
            <div className="table-card">
                {loading ? <Spinner /> : filtrados.length === 0 ? <Empty texto={busq ? 'Sin resultados.' : 'No hay destinos aún.'} /> : (
                    <div className="table-responsive">
                        <table className="custom-table">
                            <thead><tr><th>ID</th><th>Destino</th><th>Ciudad</th><th>País</th><th>Descripción</th><th>Acciones</th></tr></thead>
                            <tbody>
                                {filtrados.map(d => (
                                    <tr key={d.id}>
                                        <td><span className="badge-id">#{d.id}</span></td>
                                        <td className="td-name">{d.nombre_destino}</td>
                                        <td><span className="badge-blue">{d.ciudad}</span></td>
                                        <td><span className="badge-cat">{d.pais}</span></td>
                                        <td className="td-desc">{d.descripcion || <span className="no-data">Sin descripción</span>}</td>
                                        <td><div className="action-buttons">
                                            <button className="btn-action edit" onClick={() => editarM(d)}>✏️ Editar</button>
                                            <button className="btn-action delete" onClick={() => eliminar(d.id, d.nombre_destino)}>🗑️ Eliminar</button>
                                        </div></td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
            {modal && (
                <div className="modal-overlay">
                    <div className="modal-card">
                        <div className="modal-header">
                            <h3>{edit ? '✏️ Editar Destino' : '➕ Nuevo Destino'}</h3>
                            <button className="close-btn" onClick={cerrar}>&times;</button>
                        </div>
                        <form onSubmit={guardar} className="modal-form">
                            <Field label="Nombre del Destino" required><input type="text" value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Ej. Cartagena Colonial" required /></Field>
                            <div className="form-row">
                                <Field label="Ciudad" required><input type="text" value={ciudad} onChange={e=>setCiudad(e.target.value)} placeholder="Ciudad" required /></Field>
                                <Field label="País" required><input type="text" value={pais} onChange={e=>setPais(e.target.value)} placeholder="País" required /></Field>
                            </div>
                            <Field label="Descripción"><textarea className="custom-textarea" value={descripcion} onChange={e=>setDescripcion(e.target.value)} rows={3} placeholder="Breve descripción del destino…" /></Field>
                            <div className="modal-actions">
                                <button type="button" className="btn-secondary" onClick={cerrar}>Cancelar</button>
                                <button type="submit" className="btn-primary">{edit ? 'Actualizar' : 'Guardar'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

/* ── TAB PAQUETES ───────────────────────────────────────── */
function TabPaquetes({ paquetes, destinos, reload, flash, loading }) {
    const [busq, setBusq]     = useState('');
    const [modal, setModal]   = useState(false);
    const [edit, setEdit]     = useState(false);
    const [selId, setSelId]   = useState(null);
    const [nombre, setNombre] = useState('');
    const [precio, setPrecio] = useState('');
    const [dias, setDias]     = useState('');
    const [destino, setDestino] = useState('');

    const limpiar = () => { setNombre(''); setPrecio(''); setDias(''); setDestino(''); setSelId(null); setEdit(false); };
    const abrir   = () => { limpiar(); setModal(true); };
    const editarM = (p) => { setSelId(p.id); setNombre(p.nombre_paquete); setPrecio(p.precio); setDias(p.duracion_dias); setDestino(p.destino); setEdit(true); setModal(true); };
    const cerrar  = () => { setModal(false); limpiar(); };

    const guardar = async (e) => {
        e.preventDefault();
        if (!destino) { flash('err', 'Selecciona un destino.'); return; }
        const data = { nombre_paquete: nombre, precio: parseFloat(precio), duracion_dias: parseInt(dias), destino };
        try {
            if (edit) { await actualizarPaquete(selId, data); flash('ok', 'Paquete actualizado ✓'); }
            else       { await crearPaquete(data);             flash('ok', 'Paquete creado ✓'); }
            cerrar(); reload();
        } catch (err) {
            const msg = err.response?.data ? Object.values(err.response.data).flat()[0] : 'Error al guardar.';
            flash('err', String(msg));
        }
    };

    const eliminar = async (id, nombre) => {
        if (!window.confirm(`¿Eliminar el paquete "${nombre}"?`)) return;
        try { await eliminarPaquete(id); flash('ok', 'Paquete eliminado ✓'); reload(); }
        catch { flash('err', 'No se pudo eliminar el paquete.'); }
    };

    const filtrados = paquetes.filter(p =>
        `${p.nombre_paquete} ${p.nombre_destino||''}`.toLowerCase().includes(busq.toLowerCase())
    );

    return (
        <div>
            <div className="page-header">
                <div><h1>Paquetes Turísticos 🎒</h1><p className="page-sub">Paquetes disponibles vinculados a destinos.</p></div>
                <button className="btn-primary" onClick={abrir}>➕ Nuevo Paquete</button>
            </div>
            <input className="search-input" placeholder="🔍 Buscar paquete o destino…" value={busq} onChange={e => setBusq(e.target.value)} />
            <div className="table-card">
                {loading ? <Spinner /> : filtrados.length === 0 ? <Empty texto={busq ? 'Sin resultados.' : 'No hay paquetes aún.'} /> : (
                    <div className="table-responsive">
                        <table className="custom-table">
                            <thead><tr><th>ID</th><th>Paquete</th><th>Destino</th><th>Precio</th><th>Duración</th><th>Acciones</th></tr></thead>
                            <tbody>
                                {filtrados.map(p => (
                                    <tr key={p.id}>
                                        <td><span className="badge-id">#{p.id}</span></td>
                                        <td className="td-name">{p.nombre_paquete}</td>
                                        <td><span className="badge-cat">📍 {p.nombre_destino}</span></td>
                                        <td className="td-price">${parseFloat(p.precio).toLocaleString('es-CO', {minimumFractionDigits:2})}</td>
                                        <td><span className="badge-blue">🗓️ {p.duracion_dias} días</span></td>
                                        <td><div className="action-buttons">
                                            <button className="btn-action edit" onClick={() => editarM(p)}>✏️ Editar</button>
                                            <button className="btn-action delete" onClick={() => eliminar(p.id, p.nombre_paquete)}>🗑️ Eliminar</button>
                                        </div></td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
            {modal && (
                <div className="modal-overlay">
                    <div className="modal-card">
                        <div className="modal-header">
                            <h3>{edit ? '✏️ Editar Paquete' : '➕ Nuevo Paquete'}</h3>
                            <button className="close-btn" onClick={cerrar}>&times;</button>
                        </div>
                        <form onSubmit={guardar} className="modal-form">
                            <Field label="Nombre del Paquete" required><input type="text" value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Ej. Tour Costa Caribe 5 días" required /></Field>
                            <Field label="Destino" required>
                                <select className="custom-select" value={destino} onChange={e=>setDestino(e.target.value)} required>
                                    <option value="">— Seleccionar destino —</option>
                                    {destinos.map(d => <option key={d.id} value={d.id}>{d.nombre_destino} — {d.ciudad}</option>)}
                                </select>
                            </Field>
                            <div className="form-row">
                                <Field label="Precio ($)" required><input type="number" step="0.01" min="0" value={precio} onChange={e=>setPrecio(e.target.value)} placeholder="0.00" required /></Field>
                                <Field label="Duración (días)" required><input type="number" min="1" value={dias} onChange={e=>setDias(e.target.value)} placeholder="7" required /></Field>
                            </div>
                            <div className="modal-actions">
                                <button type="button" className="btn-secondary" onClick={cerrar}>Cancelar</button>
                                <button type="submit" className="btn-primary">{edit ? 'Actualizar' : 'Guardar'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

/* ── TAB RESERVAS ───────────────────────────────────────── */
function TabReservas({ reservas, clientes, paquetes, reload, flash, loading }) {
    const [busq, setBusq]       = useState('');
    const [modal, setModal]     = useState(false);
    const [edit, setEdit]       = useState(false);
    const [selId, setSelId]     = useState(null);
    const [fecha, setFecha]     = useState('');
    const [personas, setPersonas] = useState('');
    const [estado, setEstado]   = useState('Pendiente');
    const [cliente, setCliente] = useState('');
    const [paquete, setPaquete] = useState('');

    const limpiar = () => { setFecha(''); setPersonas(''); setEstado('Pendiente'); setCliente(''); setPaquete(''); setSelId(null); setEdit(false); };
    const abrir   = () => { limpiar(); setModal(true); };
    const editarM = (r) => { setSelId(r.id); setFecha(r.fecha_reserva); setPersonas(r.cantidad_personas); setEstado(r.estado); setCliente(r.cliente); setPaquete(r.paquete); setEdit(true); setModal(true); };
    const cerrar  = () => { setModal(false); limpiar(); };

    const guardar = async (e) => {
        e.preventDefault();
        if (!cliente || !paquete) { flash('err', 'Selecciona cliente y paquete.'); return; }
        const data = { fecha_reserva: fecha, cantidad_personas: parseInt(personas), estado, cliente, paquete };
        try {
            if (edit) { await actualizarReserva(selId, data); flash('ok', 'Reserva actualizada ✓'); }
            else       { await crearReserva(data);             flash('ok', 'Reserva creada ✓'); }
            cerrar(); reload();
        } catch (err) {
            const msg = err.response?.data ? Object.values(err.response.data).flat()[0] : 'Error al guardar.';
            flash('err', String(msg));
        }
    };

    const eliminar = async (id) => {
        if (!window.confirm('¿Eliminar esta reserva?')) return;
        try { await eliminarReserva(id); flash('ok', 'Reserva eliminada ✓'); reload(); }
        catch { flash('err', 'No se pudo eliminar la reserva.'); }
    };

    const pillClass = (e) => e === 'Confirmada' ? 'confirmada' : e === 'Cancelada' ? 'cancelada' : 'pendiente';

    const filtrados = reservas.filter(r =>
        `${r.nombre_cliente||''} ${r.apellido_cliente||''} ${r.nombre_paquete||''} ${r.estado}`.toLowerCase().includes(busq.toLowerCase())
    );

    return (
        <div>
            <div className="page-header">
                <div><h1>Reservas 📅</h1><p className="page-sub">Control de reservas y sus estados.</p></div>
                <button className="btn-primary" onClick={abrir}>➕ Nueva Reserva</button>
            </div>
            <input className="search-input" placeholder="🔍 Buscar por cliente, paquete o estado…" value={busq} onChange={e => setBusq(e.target.value)} />
            <div className="table-card">
                {loading ? <Spinner /> : filtrados.length === 0 ? <Empty texto={busq ? 'Sin resultados.' : 'No hay reservas aún.'} /> : (
                    <div className="table-responsive">
                        <table className="custom-table">
                            <thead><tr><th>ID</th><th>Cliente</th><th>Paquete</th><th>Fecha</th><th>Personas</th><th>Estado</th><th>Acciones</th></tr></thead>
                            <tbody>
                                {filtrados.map(r => (
                                    <tr key={r.id}>
                                        <td><span className="badge-id">#{r.id}</span></td>
                                        <td className="td-name">{r.nombre_cliente} {r.apellido_cliente}</td>
                                        <td><span className="badge-cat">🎒 {r.nombre_paquete}</span></td>
                                        <td>{r.fecha_reserva}</td>
                                        <td><span className="badge-yellow">👥 {r.cantidad_personas}</span></td>
                                        <td><span className={`status-pill ${pillClass(r.estado)}`}>{r.estado}</span></td>
                                        <td><div className="action-buttons">
                                            <button className="btn-action edit" onClick={() => editarM(r)}>✏️ Editar</button>
                                            <button className="btn-action delete" onClick={() => eliminar(r.id)}>🗑️ Eliminar</button>
                                        </div></td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
            {modal && (
                <div className="modal-overlay">
                    <div className="modal-card modal-wide">
                        <div className="modal-header">
                            <h3>{edit ? '✏️ Editar Reserva' : '➕ Nueva Reserva'}</h3>
                            <button className="close-btn" onClick={cerrar}>&times;</button>
                        </div>
                        <form onSubmit={guardar} className="modal-form">
                            <div className="form-row">
                                <Field label="Cliente" required>
                                    <select className="custom-select" value={cliente} onChange={e=>setCliente(e.target.value)} required>
                                        <option value="">— Seleccionar cliente —</option>
                                        {clientes.map(c => <option key={c.id} value={c.id}>{c.nombre} {c.apellido} — {c.cedula}</option>)}
                                    </select>
                                </Field>
                                <Field label="Paquete Turístico" required>
                                    <select className="custom-select" value={paquete} onChange={e=>setPaquete(e.target.value)} required>
                                        <option value="">— Seleccionar paquete —</option>
                                        {paquetes.map(p => <option key={p.id} value={p.id}>{p.nombre_paquete} (${p.precio})</option>)}
                                    </select>
                                </Field>
                            </div>
                            <div className="form-row">
                                <Field label="Fecha de Reserva" required><input type="date" value={fecha} onChange={e=>setFecha(e.target.value)} required /></Field>
                                <Field label="Cantidad de Personas" required><input type="number" min="1" value={personas} onChange={e=>setPersonas(e.target.value)} placeholder="1" required /></Field>
                            </div>
                            <Field label="Estado" required>
                                <select className="custom-select" value={estado} onChange={e=>setEstado(e.target.value)}>
                                    <option value="Pendiente">Pendiente</option>
                                    <option value="Confirmada">Confirmada</option>
                                    <option value="Cancelada">Cancelada</option>
                                </select>
                            </Field>
                            <div className="modal-actions">
                                <button type="button" className="btn-secondary" onClick={cerrar}>Cancelar</button>
                                <button type="submit" className="btn-primary">{edit ? 'Actualizar' : 'Guardar'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

/* ── TAB PAGOS ──────────────────────────────────────────── */
function TabPagos({ pagos, reservas, reload, flash, loading }) {
    const [busq, setBusq]       = useState('');
    const [modal, setModal]     = useState(false);
    const [edit, setEdit]       = useState(false);
    const [selId, setSelId]     = useState(null);
    const [fecha, setFecha]     = useState('');
    const [monto, setMonto]     = useState('');
    const [metodo, setMetodo]   = useState('Efectivo');
    const [reserva, setReserva] = useState('');

    const limpiar = () => { setFecha(''); setMonto(''); setMetodo('Efectivo'); setReserva(''); setSelId(null); setEdit(false); };
    const abrir   = () => { limpiar(); setModal(true); };
    const editarM = (p) => { setSelId(p.id); setFecha(p.fecha_pago); setMonto(p.monto); setMetodo(p.metodo_pago); setReserva(p.reserva); setEdit(true); setModal(true); };
    const cerrar  = () => { setModal(false); limpiar(); };

    const guardar = async (e) => {
        e.preventDefault();
        if (!reserva) { flash('err', 'Selecciona una reserva.'); return; }
        const data = { fecha_pago: fecha, monto: parseFloat(monto), metodo_pago: metodo, reserva };
        try {
            if (edit) { await actualizarPago(selId, data); flash('ok', 'Pago actualizado ✓'); }
            else       { await crearPago(data);             flash('ok', 'Pago registrado ✓'); }
            cerrar(); reload();
        } catch (err) {
            const msg = err.response?.data ? Object.values(err.response.data).flat()[0] : 'Error al guardar.';
            flash('err', String(msg));
        }
    };

    const eliminar = async (id) => {
        if (!window.confirm('¿Eliminar este pago?')) return;
        try { await eliminarPago(id); flash('ok', 'Pago eliminado ✓'); reload(); }
        catch { flash('err', 'No se pudo eliminar el pago.'); }
    };

    const metodoBadge = (m) => m === 'Efectivo' ? 'badge-green' : m === 'Tarjeta' ? 'badge-blue' : 'badge-cat';

    const filtrados = pagos.filter(p =>
        `${p.metodo_pago} ${p.reserva_info||''}`.toLowerCase().includes(busq.toLowerCase())
    );

    return (
        <div>
            <div className="page-header">
                <div><h1>Pagos 💳</h1><p className="page-sub">Registro de pagos asociados a reservas.</p></div>
                <button className="btn-primary" onClick={abrir}>➕ Registrar Pago</button>
            </div>
            <input className="search-input" placeholder="🔍 Buscar por método o reserva…" value={busq} onChange={e => setBusq(e.target.value)} />
            <div className="table-card">
                {loading ? <Spinner /> : filtrados.length === 0 ? <Empty texto={busq ? 'Sin resultados.' : 'No hay pagos registrados.'} /> : (
                    <div className="table-responsive">
                        <table className="custom-table">
                            <thead><tr><th>ID</th><th>Reserva</th><th>Fecha</th><th>Monto</th><th>Método</th><th>Acciones</th></tr></thead>
                            <tbody>
                                {filtrados.map(p => (
                                    <tr key={p.id}>
                                        <td><span className="badge-id">#{p.id}</span></td>
                                        <td className="td-desc">{p.reserva_info || `Reserva #${p.reserva}`}</td>
                                        <td>{p.fecha_pago}</td>
                                        <td className="td-price">${parseFloat(p.monto).toLocaleString('es-CO', {minimumFractionDigits:2})}</td>
                                        <td><span className={metodoBadge(p.metodo_pago)}>{p.metodo_pago}</span></td>
                                        <td><div className="action-buttons">
                                            <button className="btn-action edit" onClick={() => editarM(p)}>✏️ Editar</button>
                                            <button className="btn-action delete" onClick={() => eliminar(p.id)}>🗑️ Eliminar</button>
                                        </div></td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
            {modal && (
                <div className="modal-overlay">
                    <div className="modal-card">
                        <div className="modal-header">
                            <h3>{edit ? '✏️ Editar Pago' : '➕ Registrar Pago'}</h3>
                            <button className="close-btn" onClick={cerrar}>&times;</button>
                        </div>
                        <form onSubmit={guardar} className="modal-form">
                            <Field label="Reserva Asociada" required>
                                <select className="custom-select" value={reserva} onChange={e=>setReserva(e.target.value)} required>
                                    <option value="">— Seleccionar reserva —</option>
                                    {reservas.map(r => <option key={r.id} value={r.id}>Reserva #{r.id} — {r.nombre_cliente} {r.apellido_cliente} ({r.estado})</option>)}
                                </select>
                            </Field>
                            <div className="form-row">
                                <Field label="Fecha de Pago" required><input type="date" value={fecha} onChange={e=>setFecha(e.target.value)} required /></Field>
                                <Field label="Monto ($)" required><input type="number" step="0.01" min="0" value={monto} onChange={e=>setMonto(e.target.value)} placeholder="0.00" required /></Field>
                            </div>
                            <Field label="Método de Pago" required>
                                <select className="custom-select" value={metodo} onChange={e=>setMetodo(e.target.value)}>
                                    <option value="Efectivo">💵 Efectivo</option>
                                    <option value="Tarjeta">💳 Tarjeta de Crédito/Débito</option>
                                    <option value="Transferencia">🏦 Transferencia Bancaria</option>
                                </select>
                            </Field>
                            <div className="modal-actions">
                                <button type="button" className="btn-secondary" onClick={cerrar}>Cancelar</button>
                                <button type="submit" className="btn-primary">{edit ? 'Actualizar' : 'Registrar'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}

/* ── TAB GUÍAS ──────────────────────────────────────────── */
function TabGuias({ guias, destinos, reload, flash, loading }) {
    const [busq, setBusq]           = useState('');
    const [modal, setModal]         = useState(false);
    const [edit, setEdit]           = useState(false);
    const [selId, setSelId]         = useState(null);
    const [nombre, setNombre]       = useState('');
    const [telefono, setTelefono]   = useState('');
    const [experiencia, setExperiencia] = useState('');
    const [destino, setDestino]     = useState('');

    const limpiar = () => { setNombre(''); setTelefono(''); setExperiencia(''); setDestino(''); setSelId(null); setEdit(false); };
    const abrir   = () => { limpiar(); setModal(true); };
    const editarM = (g) => { setSelId(g.id); setNombre(g.nombre); setTelefono(g.telefono); setExperiencia(g.experiencia); setDestino(g.destino); setEdit(true); setModal(true); };
    const cerrar  = () => { setModal(false); limpiar(); };

    const guardar = async (e) => {
        e.preventDefault();
        if (!destino) { flash('err', 'Selecciona un destino.'); return; }
        const data = { nombre, telefono, experiencia, destino };
        try {
            if (edit) { await actualizarGuia(selId, data); flash('ok', 'Guía actualizado ✓'); }
            else       { await crearGuia(data);             flash('ok', 'Guía creado ✓'); }
            cerrar(); reload();
        } catch (err) {
            const msg = err.response?.data ? Object.values(err.response.data).flat()[0] : 'Error al guardar.';
            flash('err', String(msg));
        }
    };

    const eliminar = async (id, nombre) => {
        if (!window.confirm(`¿Eliminar al guía "${nombre}"?`)) return;
        try { await eliminarGuia(id); flash('ok', 'Guía eliminado ✓'); reload(); }
        catch { flash('err', 'No se pudo eliminar el guía.'); }
    };

    const filtrados = guias.filter(g =>
        `${g.nombre} ${g.experiencia} ${g.nombre_destino||''}`.toLowerCase().includes(busq.toLowerCase())
    );

    return (
        <div>
            <div className="page-header">
                <div><h1>Guías Turísticos 👨‍💼</h1><p className="page-sub">Gestión de guías asignados por destino.</p></div>
                <button className="btn-primary" onClick={abrir}>➕ Nuevo Guía</button>
            </div>
            <input className="search-input" placeholder="🔍 Buscar por nombre, destino o experiencia…" value={busq} onChange={e => setBusq(e.target.value)} />
            <div className="table-card">
                {loading ? <Spinner /> : filtrados.length === 0 ? <Empty texto={busq ? 'Sin resultados.' : 'No hay guías registrados.'} /> : (
                    <div className="table-responsive">
                        <table className="custom-table">
                            <thead><tr><th>ID</th><th>Nombre</th><th>Teléfono</th><th>Experiencia</th><th>Destino</th><th>Acciones</th></tr></thead>
                            <tbody>
                                {filtrados.map(g => (
                                    <tr key={g.id}>
                                        <td><span className="badge-id">#{g.id}</span></td>
                                        <td className="td-name">{g.nombre}</td>
                                        <td>{g.telefono}</td>
                                        <td><span className="badge-green">{g.experiencia}</span></td>
                                        <td><span className="badge-cat">📍 {g.nombre_destino}</span></td>
                                        <td><div className="action-buttons">
                                            <button className="btn-action edit" onClick={() => editarM(g)}>✏️ Editar</button>
                                            <button className="btn-action delete" onClick={() => eliminar(g.id, g.nombre)}>🗑️ Eliminar</button>
                                        </div></td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
            {modal && (
                <div className="modal-overlay">
                    <div className="modal-card">
                        <div className="modal-header">
                            <h3>{edit ? '✏️ Editar Guía' : '➕ Nuevo Guía'}</h3>
                            <button className="close-btn" onClick={cerrar}>&times;</button>
                        </div>
                        <form onSubmit={guardar} className="modal-form">
                            <Field label="Nombre del Guía" required><input type="text" value={nombre} onChange={e=>setNombre(e.target.value)} placeholder="Nombre completo" required /></Field>
                            <div className="form-row">
                                <Field label="Teléfono" required><input type="text" value={telefono} onChange={e=>setTelefono(e.target.value)} placeholder="+57 300 000 0000" required /></Field>
                                <Field label="Experiencia" required><input type="text" value={experiencia} onChange={e=>setExperiencia(e.target.value)} placeholder="Ej. 5 años" required /></Field>
                            </div>
                            <Field label="Destino Asignado" required>
                                <select className="custom-select" value={destino} onChange={e=>setDestino(e.target.value)} required>
                                    <option value="">— Seleccionar destino —</option>
                                    {destinos.map(d => <option key={d.id} value={d.id}>{d.nombre_destino} — {d.ciudad}</option>)}
                                </select>
                            </Field>
                            <div className="modal-actions">
                                <button type="button" className="btn-secondary" onClick={cerrar}>Cancelar</button>
                                <button type="submit" className="btn-primary">{edit ? 'Actualizar' : 'Guardar'}</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
