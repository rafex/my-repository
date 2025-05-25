use crate::curp_generator::logic::generar_curp;
use crate::curp_generator::logic::DatosPersonales;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn generar_curp_c(datos: *const DatosPersonales) -> *mut c_char {
    unsafe {
        if datos.is_null() {
            return std::ptr::null_mut();
        }
        let datos = &*datos;

        let nombre = CStr::from_ptr(datos.nombre).to_string_lossy().to_string();
        let primer_apellido = CStr::from_ptr(datos.primer_apellido).to_string_lossy().to_string();
        let segundo_apellido = CStr::from_ptr(datos.segundo_apellido).to_string_lossy().to_string();
        let sexo = datos.sexo as u8 as char;
        let fecha_nacimiento = CStr::from_ptr(datos.fecha_nacimiento).to_string_lossy().to_string();
        let entidad = CStr::from_ptr(datos.entidad).to_string_lossy().to_string();

        let curp = generar_curp(&nombre, &primer_apellido, &segundo_apellido, sexo, &fecha_nacimiento, &entidad);
        CString::new(curp).unwrap().into_raw()
    }
}