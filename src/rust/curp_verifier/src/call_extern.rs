use crate::curp_verifier::logic::verificar_curp;
use std::ffi::CStr;
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn verify_curp(curp: *const c_char) -> bool {
    if curp.is_null() {
        return false;
    }
    let c_str = unsafe { CStr::from_ptr(curp) };
    match c_str.to_str() {
        Ok(rust_str) => verificar_curp(rust_str),
        Err(_) => false,
    }
}