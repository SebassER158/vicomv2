import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {

  String server = "http://72.167.33.202:2020";
  // String server = "http://193.203.165.213:2025";

  static String buildImageUrl(dynamic pathStr) {
    if (pathStr == null) return "";
    String path = pathStr.toString();
    if (path.isEmpty) return "";
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return path;
    }
    return "http://72.167.33.202$path";
  }

  saveTareas(
      String cuenta, int tienda, String tarea, String comentario) async {
    var url = "$server/postSaveTareas";
    return await http.post(Uri.parse(url),
        body: json.encode({
          "db": cuenta,
          "tienda": tienda,
          "tarea": tarea,
          "comentario": comentario
        }),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        });
  }

  postSaveTareasFoto(
      int tienda, String tarea, String comentario, String cuenta, String nombre, String imagen64) async {
    var url = "$server/postSaveTareasFoto";
    return await http.post(Uri.parse(url),
        body: json.encode({
          "tienda": tienda,
          "nombre_imgF": nombre,
          "imgF": imagen64,
          "tarea": tarea,
          "comentario": comentario,
          "db": cuenta
        }),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        });
  }

  postSaveTareasFotoAsignadas(
      int tienda, String tarea, String comentario, String cuenta, String nombre, String imagen64) async {
    var url = "$server/postSaveTareasFotoAsignadas";
    return await http.post(Uri.parse(url),
        body: json.encode({
          "tienda": tienda,
          "nombre_imgF": nombre,
          "imgF": imagen64,
          "tarea": tarea,
          "comentario": comentario,
          "db": cuenta
        }),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        });
  }

  getActividades(String cuenta, int id, String fecha) async{
    var url = "$server/getActividadesPromotor/$cuenta/$id/$fecha";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getValoresTabla(String cuenta, String tabla) async{
    var url = "$server/getTableListValues/$cuenta/$tabla";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getFechaCadena(String cuenta, String cadena) async{
    var url = "$server/getFechaCadena/$cuenta/$cadena";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getUltimaVisita(String cuenta, int tiendaId) async{
    var url = "$server/getUltimaVisita/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTotalVisitas(String cuenta, int tiendaId) async{
    var url = "$server/getTotalVisitas/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTotalVisitasDetalle(String cuenta, int tiendaId) async{
    var url = "$server/getTotalVisitasDetalle/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEstadiaTienda(String cuenta, int tiendaId) async{
    var url = "$server/getEstadiaTienda/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTotalEstadia(String cuenta, int tiendaId) async{
    var url = "$server/getTotalEstadia/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getObjetivosPc(String cuenta, int tiendaId) async{
    var url = "$server/getObjetivosPc/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEjecutadoPc(String cuenta, int tiendaId) async{
    var url = "$server/getEjecutadoPc/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getAvancePc(String cuenta, int tiendaId) async{
    var url = "$server/getAvancePc/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPcEjecutado(String cuenta, int tiendaId) async{
    var url = "$server/getPcEjecutado/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPcPendiente(String cuenta, int tiendaId) async{
    var url = "$server/getPcPendiente/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getObjetivosEx(String cuenta, int tiendaId) async{
    var url = "$server/getObjetivosEx/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEjecutadoEx(String cuenta, int tiendaId) async{
    var url = "$server/getEjecutadoEx/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getAvanceEx(String cuenta, int tiendaId) async{
    var url = "$server/getAvanceEx/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getObjetivosLi(String cuenta, int tiendaId) async{
    var url = "$server/getObjetivosLi/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEjecutadoLi(String cuenta, int tiendaId) async{
    var url = "$server/getEjecutadoLi/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getAvanceLi(String cuenta, int tiendaId) async{
    var url = "$server/getAvanceLi/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getFrentesTienda(String cuenta, int tiendaId) async{
    var url = "$server/getFrentesTienda/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPromedioCadena(String cuenta, int tiendaId) async{
    var url = "$server/getPromedioCadena/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPromedioFrentesMarca(String cuenta, int tiendaId) async{
    var url = "$server/getPromedioFrentesMarca/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getCumplimientoVisita(String cuenta, int tiendaId) async{
    var url = "$server/getCumplimientoVisita/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosSo(String cuenta, String cadena, int determinante) async{
    var url = "$server/getDatosSo/$cuenta/$cadena/$determinante";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosPuntosControl(String cuenta, int tiendaId) async{
    var url = "$server/getDatosPuntosControl/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosExhibicion(String cuenta, int tiendaId) async{
    var url = "$server/getDatosExhibicion/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosLineal(String cuenta, int tiendaId) async{
    var url = "$server/getDatosLineal/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getExhibicionesPrueba(String cuenta, int tiendaId) async{
    var url = "$server/getExhibicionesPrueba/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTareasAsignadasMes(String cuenta, int tiendaId) async{
    var url = "$server/getTareasAsignadasMes/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTareasRealizadas(String cuenta, int tiendaId) async{
    var url = "$server/getTareasRealizadas/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTareasPendientes(String cuenta, int tiendaId) async{
    var url = "$server/getTareasPendientes/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  saveModelos(String cuenta, int user_id, String modelo) async{
    var url = "$server/saveModelos/$cuenta/$user_id/$modelo";
    return await http.get(Uri.parse(url));
  }

  getUserLogin(String cuenta, String user, String pass) async{
    var url = "$server/getUserLogin/$cuenta/$user/$pass";
    return await http.get(Uri.parse(url));
  }

  getUserLoginInfo(String cuenta, String user, String pass) async{
    var url = "$server/getUserLoginInfo/$cuenta/$user/$pass";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getCheckTareas(String cuenta, String tarea, int tienda) async{
    var url = "$server/getCheckTareas/$cuenta/$tarea/$tienda";
    return await http.get(Uri.parse(url));
  }

  getCheckTareasAsignadas(String cuenta, String tarea, int tienda) async{
    var url = "$server/getCheckTareasAsignadas/$cuenta/$tarea/$tienda";
    return await http.get(Uri.parse(url));
  }

  getAvailableModules(String cuenta) async{
    var url = "$server/getAvailableModules/$cuenta";
    return await http.get(Uri.parse(url));
  }

  getValuesTableByValor(String cuenta, String tabla, String condicion, String valor) async{
    var url = "$server/getValuesTableByValor/$cuenta/$tabla/$condicion/$valor";
    return await http.get(Uri.parse(url));
  }

}