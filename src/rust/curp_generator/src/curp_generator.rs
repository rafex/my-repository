pub mod logic {
    use std::os::raw::c_char;

    #[repr(C)]
    pub struct DatosPersonales {
        pub nombre: *const c_char,
        pub primer_apellido: *const c_char,
        pub segundo_apellido: *const c_char,
        pub sexo: c_char, // 'H' o 'M'
        pub fecha_nacimiento: *const c_char, // "AAAA-MM-DD"
        pub entidad: *const c_char,
    }
    
    pub fn generar_curp(nombre: &str, primer_apellido: &str, segundo_apellido: &str, sexo: char, fecha_nacimiento: &str, entidad: &str) -> String {
        let mut curp = String::new();

        let inicial1 = primer_apellido.chars().next().unwrap_or('X');
        let vocal_interna = primer_apellido.chars().skip(1).find(|c| "AEIOUaeiou".contains(*c)).unwrap_or('X');
        let inicial2 = segundo_apellido.chars().next().unwrap_or('X');
        let inicial3 = nombre.chars().next().unwrap_or('X');

        curp.push(inicial1);
        curp.push(vocal_interna);
        curp.push(inicial2);
        curp.push(inicial3);

        let partes: Vec<&str> = fecha_nacimiento.split('-').collect();
        if partes.len() == 3 {
            curp.push_str(&partes[0][2..4]); // AA
            curp.push_str(partes[1]);        // MM
            curp.push_str(partes[2]);        // DD
        } else {
            curp.push_str("000000");
        }

        curp.push(sexo);
        curp.push_str(&entidad.to_uppercase());

        curp.push(extraer_consonante_interna(primer_apellido));
        curp.push(extraer_consonante_interna(segundo_apellido));
        curp.push(extraer_consonante_interna(nombre));

        let siglo = partes[0].parse::<i32>().unwrap_or(1900);
        curp.push(if siglo < 2000 { '0' } else { 'A' });

        curp.push('0');

        curp.to_uppercase()
    }

    fn extraer_consonante_interna(cadena: &str) -> char {
        cadena.chars()
            .skip(1)
            .find(|c| !"AEIOUaeiou".contains(*c) && c.is_alphabetic())
            .unwrap_or('X')
    }
}
