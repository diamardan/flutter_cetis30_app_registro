class AppConstants {
  //backendUrl hace referencia ya sea a la url de producción o a la de desarrollo
  static const backendUrl = 'https://escuelas.identaflix.com/api/v1/firebase';
  //static const backendUrl = 'http://192.168.1.64:5000/api/v1/firebase';
  static const backendPublicUrl = 'https://escuelas.identaflix.com/public';
  static const backendBaseUrl = 'https://escuelas.identaflix.com/api/v1';
  //static const whatsappNumber = '+5215520779800';
  static const whatsappNumber = '+5215561146039';
  static const supportNumber = '5561146039';
  static const whatsappText = 'Hola me comunico del Cetis 30';
  static const accesosById = backendUrl + '/cetis30/accesos/getAllById';
  static const accesosAll = backendUrl + '/cetis30/accesos/getAll';

  static const pdfPagoUrl =
      "https://escuelas.identaflix.com/public/pdfs/LUMEN%20FORMATO%20PAGO.pdf";
  static const urlAttendance = "https://attendance-lumen.web.app/";
  static const urlAttendanceIdPosition = 33;
  //fsCollectionName almacena el nombre de la collection que hace referencia a la escuela sobre la que se va a trabajar
  static const fsCollectionName = "cetis30";
  //éste link es el de la carpeta del google drive credenciales
  static const gdriveUrl =
      "https://drive.google.com/drive/folders/1u06DdjAA3RxWwc7EyYGWjia_gxLBNHhS?usp=sharing";
}
