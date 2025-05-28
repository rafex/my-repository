# my-repository

Este proyecto lo realicé para tener disponible en repositorios programas y utilidades que he desarrollado **porque puedo hacerlo**. Su propósito es facilitar mi existencia en proyectos propios.

El código fuente es público y está disponible en el repositorio:  
👉 [https://github.com/rafex/my-repository](https://github.com/rafex/my-repository)

## Licencia

Este repositorio está cubierto por una licencia de código abierto. Consulta el archivo [LICENSE](./LICENSE) para más detalles.  
Para información general sobre licencias de código abierto, puedes consultar:  
- [Licencias disponibles en GitHub](https://docs.github.com/es/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)  
- [Open Source Initiative (OSI)](https://opensource.org/licenses)

## Sugerencias para agregar

- ✨ Ejemplos de uso de los scripts o utilidades.
- 🛠 Requisitos y cómo instalar dependencias.
- 📁 Estructura del proyecto (breve descripción de carpetas).
- 📌 Objetivos futuros o TODO list.
- 🤝 Cómo contribuir (agregar un `CONTRIBUTING.md`).
- 🧪 Tests o cómo probar funcionalidades.

---
¡Hecho para facilitarme la vida!

> ✅ El repositorio ya cuenta con firma GPG. Puedes configurarlo de forma segura así:

```bash
curl -fsSL https://repository.rafex.app/pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/rafex-archive-keyring.gpg echo "deb [signed-by=/usr/share/keyrings/rafex-archive-keyring.gpg] https://repository.rafex.app/debian stable main" | sudo tee /etc/apt/sources.list.d/rafex.list > /dev/null
sudo apt update
sudo apt install curp-verifier
```