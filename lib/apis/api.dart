import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {

  
  saveTareas(
      String cuenta, int tienda, String tarea, String comentario) async {
    var url = "http://72.167.33.202:2020/postSaveTareas";
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
    var url = "http://72.167.33.202:2020/postSaveTareasFoto";
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

  // getDatos(int id) async{
  //   var url = "http://51.222.136.150:3131/getValoresByEjecutivo/usuarios/$id";
  //   print(url);
  //   return await http.get(Uri.parse(url));
  // }

  // getDatosById(String tabla, int id) async{
  //   var url = "http://51.222.136.150:3131/getValoresById/$tabla/$id";
  //   print(url);
  //   return await http.get(Uri.parse(url));
  // }

  getActividades(String cuenta, int id, String fecha) async{
    var url = "http://72.167.33.202:2020/getActividadesPromotor/$cuenta/$id/$fecha";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTiendas(String cuenta, String tabla) async{
    var url = "http://72.167.33.202:2020/getTableListValues/$cuenta/$tabla";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getUltimaVisita(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getUltimaVisita/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTotalVisitas(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getTotalVisitas/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTotalVisitasDetalle(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getTotalVisitasDetalle/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEstadiaTienda(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getEstadiaTienda/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTotalEstadia(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getTotalEstadia/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getObjetivosPc(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getObjetivosPc/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEjecutadoPc(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getEjecutadoPc/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getAvancePc(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getAvancePc/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPcEjecutado(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getPcEjecutado/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPcPendiente(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getPcPendiente/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getObjetivosEx(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getObjetivosEx/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEjecutadoEx(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getEjecutadoEx/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getAvanceEx(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getAvanceEx/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getObjetivosLi(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getObjetivosLi/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getEjecutadoLi(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getEjecutadoLi/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getAvanceLi(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getAvanceLi/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getFrentesTienda(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getFrentesTienda/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPromedioCadena(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getPromedioCadena/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getPromedioFrentesMarca(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getPromedioFrentesMarca/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getCumplimientoVisita(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getCumplimientoVisita/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosSo(String cuenta, String cadena, int determinante) async{
    var url = "http://72.167.33.202:2020/getDatosSo/$cuenta/$cadena/$determinante";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosPuntosControl(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getDatosPuntosControl/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosExhibicion(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getDatosExhibicion/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getDatosLineal(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getDatosLineal/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getExhibicionesPrueba(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getExhibicionesPrueba/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTareasAsignadasMes(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getTareasAsignadasMes/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTareasRealizadas(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getTareasRealizadas/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  getTareasPendientes(String cuenta, int tiendaId) async{
    var url = "http://72.167.33.202:2020/getTareasPendientes/$cuenta/$tiendaId";
    print(url);
    return await http.get(Uri.parse(url));
  }

  saveModelos(String cuenta, int user_id, String modelo) async{
    var url = "http://72.167.33.202:2020/saveModelos/$cuenta/$user_id/$modelo";
    return await http.get(Uri.parse(url));
  }

}