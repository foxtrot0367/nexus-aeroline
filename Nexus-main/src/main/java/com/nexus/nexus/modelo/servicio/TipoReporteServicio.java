package com.nexus.nexus.modelo.servicio;

import com.nexus.nexus.dto.ClienteReservaDTO;
import com.nexus.nexus.modelo.entidad.Cliente;
import com.nexus.nexus.modelo.entidad.Reserva;
import com.nexus.nexus.modelo.entidad.TipoReporte;
import com.nexus.nexus.modelo.entidad.Viaje;
import com.nexus.nexus.modelo.entidad.Vuelo;
import com.nexus.nexus.modelo.repositorio.ClienteRepositorio;
import com.nexus.nexus.modelo.repositorio.ReservaRepositorio;
import com.nexus.nexus.modelo.repositorio.TipoReporteRepositorio;
import com.nexus.nexus.modelo.repositorio.ViajeRepositorio;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class TipoReporteServicio implements ITipoReporteServicio {

    @Autowired
    private TipoReporteRepositorio tipoReporteRepositorio;

    @Autowired
    private ReservaRepositorio reservaRepositorio;

    @Autowired
    private ViajeRepositorio viajeRepositorio;

    @Autowired
    private ClienteRepositorio clienteRepositorio;

    @Override
    public List<TipoReporte> listarTiposReporte() {
        return tipoReporteRepositorio.findAllByOrderByIdAsc();
    }

    @Override
    public Map<String, Long> obtenerVentasPorDestino() {
        return reservaRepositorio.findAll().stream()
                .filter(reserva -> reserva.getViaje() != null)
                .collect(Collectors.groupingBy(reserva -> reserva.getViaje().getDestino(), Collectors.counting()));
    }

    @Override
    public Map<LocalDate, Long> obtenerVentasPorFecha(LocalDate fechaInicio, LocalDate fechaFin) {
        return reservaRepositorio.findByFechaReservaBetween(fechaInicio.atStartOfDay(), fechaFin.plusDays(1).atStartOfDay())
                .stream()
                .collect(Collectors.groupingBy(reserva -> reserva.getFechaReserva().toLocalDate(), Collectors.counting()));
    }

    @Override
    public long obtenerTotalReservas() {
        return reservaRepositorio.count();
    }

    @Override
    public Map<Reserva.EstadoReserva, Long> obtenerReservasPorEstado() {
        return reservaRepositorio.findAll().stream().collect(Collectors.groupingBy(reserva -> (Reserva.EstadoReserva) reserva.getEstadoReserva(), Collectors.counting()));
    }

    @Override
    public long obtenerTotalClientes() {
        return clienteRepositorio.count();
    }

    @Override
    public Map<String, Long> obtenerDestinosMasPopulares(int limit) {
        return reservaRepositorio.findAll().stream()
                .filter(reserva -> reserva.getViaje() != null)
                .collect(Collectors.groupingBy(reserva -> reserva.getViaje().getDestino(), Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(limit)
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<ClienteReservaDTO> obtenerClientesConReservas(String filtro) {
        String normalized = filtro == null ? "" : filtro.trim().toLowerCase();
        return reservaRepositorio.findAll().stream()
                .filter(reserva -> matchesClientReservationFilter(reserva, normalized))
                .map(this::toClienteReservaDto)
                .toList();
    }

    private boolean matchesClientReservationFilter(Reserva reserva, String normalized) {
        if (normalized.isEmpty()) {
            return true;
        }
        Cliente cliente = reserva.getCliente();
        if (cliente == null) {
            return false;
        }
        return containsIgnoreCase(cliente.getNombre(), normalized)
                || containsIgnoreCase(cliente.getApellido(), normalized)
                || containsIgnoreCase(cliente.getNumeroDocumento(), normalized)
                || containsIgnoreCase(cliente.getTipoDocumento(), normalized);
    }

    private boolean containsIgnoreCase(String value, String normalized) {
        return value != null && value.toLowerCase().contains(normalized);
    }

    private ClienteReservaDTO toClienteReservaDto(Reserva reserva) {
        Cliente cliente = reserva.getCliente();
        Viaje viaje = reserva.getViaje();
        Vuelo vuelo = reserva.getVuelo();
        String origen = viaje != null ? viaje.getOrigen() : (vuelo != null ? vuelo.getOrigen() : null);
        String destino = viaje != null ? viaje.getDestino() : (vuelo != null ? vuelo.getDestino() : null);
        String precio = reserva.getPrecioTotal() == null ? null : reserva.getPrecioTotal().toPlainString();
        String estado = reserva.getEstadoReserva() == null ? null : reserva.getEstadoReserva().name();
        return new ClienteReservaDTO(
                cliente != null ? cliente.getIdCliente() : null,
                cliente != null ? cliente.getNombre() : null,
                cliente != null ? cliente.getApellido() : null,
                cliente != null ? cliente.getTipoDocumento() : null,
                cliente != null ? cliente.getNumeroDocumento() : null,
                cliente != null ? cliente.getTelefono() : null,
                reserva.getIdReserva(),
                destino,
                origen,
                reserva.getFechaInicio(),
                estado,
                precio);
    }
}