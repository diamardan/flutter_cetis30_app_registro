import 'dart:io';

import 'package:cetis32_app_registro/src/screens/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cetis32_app_registro/src/constants/constants.dart';
import 'package:cetis32_app_registro/src/customWidgets/Alert.dart';
import 'package:cetis32_app_registro/src/screens/pago/payment_wrapper.dart';
import 'package:cetis32_app_registro/src/screens/preregistro/last_screen.dart';
import 'package:cetis32_app_registro/src/services/AlumnoService.dart';
import 'package:cetis32_app_registro/src/services/EspecialidadesService.dart';
import 'package:cetis32_app_registro/src/services/GruposService.dart';
import 'package:cetis32_app_registro/src/services/SemestresService.dart';
import 'package:cetis32_app_registro/src/services/SharedService.dart';
import 'package:cetis32_app_registro/src/services/TurnosService.dart';
import 'package:cetis32_app_registro/src/utils/txtFormater.dart';
import 'package:cetis32_app_registro/src/utils/validator.dart';
import 'package:signature/signature.dart';

class PreregForm extends StatefulWidget {
  PreregForm({Key key}) : super(key: key);

  @override
  _PreregFormState createState() => _PreregFormState();
}

class _PreregFormState extends State<PreregForm> {
  final AlumnoService alumnoService = AlumnoService();
  final EspecialidadesService especialidadesService = EspecialidadesService();
  final SemestresService semestresService = SemestresService();
  final GruposService gruposService = GruposService();
  final TurnosService turnosService = TurnosService();
  final SharedService sharedService = SharedService();

  final _curpAlumnoController = TextEditingController();
  final _nombreAlumnoController = TextEditingController();
  final _apellidosAlumnoController = TextEditingController();
  final _correoAlumnoController = TextEditingController();
  final _celularAlumnoController = TextEditingController();
  final _matriculaAlumnoControler = TextEditingController();

  String sexoSeleccionado;
  String especialidadSeleccionada;
  String semestreSeleccionado;
  String grupoSeleccionado;
  String turnoSeleccionado;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  int _currentStep = 0;
  bool completed = false;
  bool _loading = true;
  bool isLoading = false;
  final ValidatorsLumen validators = new ValidatorsLumen();
  final SignatureController _signController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  Map<String, dynamic> resultEsp;
  Map<String, dynamic> resultSem;
  Map<String, dynamic> resultGru;
  Map<String, dynamic> resultTur;

  Map<String, dynamic> alumno;
  List _especialidades = List();
  List _semestres = List();
  List _grupos = List();
  List _turnos = List();
  File foto;
  String foto1 = "";
  File voucher;
  String voucher1 = "";

  @override
  void initState() {
    super.initState();
    _loadSchoolData();

    setState(() {
      _loading = false;
    });
  }

  void _loadSchoolData() async {
    try {
      var careers = await sharedService.getAll("cat_carreras");
      var grades = await sharedService.getAll("cat_semestres");
      var groups = await sharedService.getAll("cat_grupos");
      var turns = await sharedService.getAll("cat_turnos");

      setState(() {
        _especialidades = careers;
        _semestres = grades;
        _grupos = groups;
        _turnos = turns;

        _loading = false;
      });
    } catch (error) {
      print(error);
    }
  }

  next() async {
    if (formKeys[_currentStep].currentState.validate()) {
      if (_currentStep < _mySteps().length - 1) {
        goTo(_currentStep + 1);
      } else {
        if (_currentStep == _mySteps().length - 1) {
          bool tieneFirma = await procesarFirma();
          if (tieneFirma == false) {
            showAlertDialog(
                context,
                "Sin firma",
                "no se puede finalizar el registro si no se captura la firma del alumno",
                "error");
          } else {
            finishForm();
          }
        }
        setState(() => completed = true);
      }
      /*  _currentStep < _mySteps().length -1
          ? goTo(_currentStep + 1)
          : setState(() => completed = true); */
    }
  }

  cancel() {
    if (_currentStep > 1) {
      goTo(_currentStep - 1);
    } else {
       Navigator.push(
          context, MaterialPageRoute(builder: (context) => InitialScreen()));
      /* Navigator.popUntil(context, ModalRoute.withName('inicio')); */
    }
  }

  Future<bool> validateCurp(int step) async {
    bool avanza = false;
    Map<String, dynamic> result;

    print('voy a validar');
    try {
      result = await alumnoService.checkCurp(_curpAlumnoController.text);
    } catch (error) {
      print('estoy en catch');
      print(error);
    }

    if (result['message'] != "SUCCESS") {
      showAlertDialog(context, "Error",
          "Ocurrió un error al conectarse al servidor", "error");
      return avanza;
    }

    if(result['code'] == 201){
     return avanza;
    }
    if (result['code'] == 200) {
      alumno = result['data'];
      setState(() {
        _nombreAlumnoController.text = alumno['nombres'];
        _apellidosAlumnoController.text = alumno['apellidos'];
        /* alumno[0]['FOTO_USUARIO'] != null ? foto1 = "${AppConstants.backendPublicUrl}/uploads/preregistro/fotos/${alumno[0]['FOTO_USUARIO']}"
        : foto1 = ""; */
      });
      if (alumno.length >= 1) {
        avanza = true;
      }
    }
    /* else {
      showAlertDialog(
          context, "Error", "Ocurrió un error al conectarse al servidor");
    } */
    print('misVotos: $result');
    /*  setState(() {
      _currentStep = result['data'] == 'SUCCESS' ? step : step - 1;
      _loading = false;
    }); */
    return avanza;
  }

  goTo(int step) async {
    bool avanzar = false;
    String title = "", message = "";
    bool mostrarFormPago = false;

    setState(() {
      _loading = true;
      isLoading = true;
    });
    switch (step) {
      case 0:
        {
          setState(() {
            _currentStep = 0;
            _loading = false;
            isLoading = false;
          });
        }
        break;
      case 1:
        {
          avanzar = await validateCurp(step);

          if (avanzar != true) {
            title = "No encontrado";
            /* message =
                "El CURP ingresado no cuenta con registro de pago . Favor de descargar el formato de pago y una vez realizado el deposito enviar foto del voucher original con el nombre y curp del alumno por WhatsApp al 5520779800";
            */
            message = "No se encontró el alumno con la C.U.R.P. ingresada, en caso de que sea correcto por favor comunicarse al 5520779800 para darlo de alta en el sistema";
;
          }
          print("puedo avanzar ? : $avanzar");
        }
        break;
      case 2:
        {
          if(avanzar != true){
          title = "¡Atención!";
          message = "Alumnos de nuevo ingreso, deberán escoger la especialidad 'COMPONENTE BÁSICO Y PROPEDEUTICO'";
          showAlertDialog(context, title, message, "warning", false);

          }
          avanzar = true;
        }
        break;
      case 3:
        {
          avanzar = true;
        }
        break;
      case 4:
        {
          if (voucher1 == "") {
            title = "Sin foto";
            message =
                "Su registro no puede continuar sin capturar la foto del voucher";
            avanzar = false;
          } else {
            avanzar = true;
          }
        }
        break;
      case 5:
        {
          if (foto1 == "") {
            title = "Sin foto";
            message =
                "Su registro no puede continuar sin capturar la foto del alumno";
            avanzar = false;
          } else {
            avanzar = true;
          }
        }
        break;
      case 6:
        {
          bool hayFirma = await procesarFirma();
          if (!hayFirma) {
            avanzar = false;
            title = "Sin firma";
            message =
                "Su registro no puede continuar sin capturar la firma del alumno";
          }
          //avanzar = true;
        }
        break;
      default:
        {
          print("defaultOption");
        }
        break;
    }
    avanzar == false ? showAlertDialog(context, title, message, "error", false) : null;
    /* if (avanzar == false && mostrarFormPago == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PaymentPage()));
    } */
    setState(() {
      _currentStep = avanzar == true ? step : step - 1;
      _loading = false;
    });
  }

  finishForm() async {
    setState(() {
      _loading = true;
    });
    Map<String, dynamic> _alumno = {};
    _alumno['nombres'] = _nombreAlumnoController.text;
    _alumno['apellidos'] = _apellidosAlumnoController.text;
    _alumno['curp'] = _curpAlumnoController.text;
    _alumno['correo'] = _correoAlumnoController.text;
    _alumno['celular'] = _celularAlumnoController.text;
    _alumno['matricula'] = _matriculaAlumnoControler.text;
    _alumno['carrera'] = especialidadSeleccionada;
    _alumno['grado'] = semestreSeleccionado;
    _alumno['grupo'] = grupoSeleccionado;
    _alumno['turno'] = turnoSeleccionado;
    _alumno['sexo'] = sexoSeleccionado;

    var firma = await _signController.toPngBytes();
    var data = Image.memory(firma);

    final finishStep = await alumnoService.finish(_alumno, voucher, foto, firma);
    final resultMessage = finishStep['message'];
    final resultCode = finishStep['code'];
    if (resultCode == 200) {
      setState(() {
        _loading = false;
        lastScreen(context);
      });
    } else {
      setState(() {
        _loading = false;
      });
      final errorHttp = finishStep['data'];
      showAlertDialog(context, "Error",
          "Ocurrió un error al conectarse al servidor, $errorHttp", "error");
    }
  }

  lastScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return LastScreen();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Proceso de Registro'),
        ),
        body: Stack(children: <Widget>[
          _loading == true
              ? showLoading()
              : Stepper(
                  controlsBuilder: (BuildContext context,
                      {VoidCallback onStepContinue,
                      VoidCallback onStepCancel}) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RaisedButton(
                          color: AppColors.morenaColor,
                          onPressed: onStepContinue,
                          child: const Text(
                            'Continuar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        RaisedButton(
                          onPressed: onStepCancel,
                          child: const Text('Atrás'),
                        ),
                      ],
                    );
                  },
                  type: StepperType.horizontal,
                  physics: ClampingScrollPhysics(),
                  currentStep: _currentStep,
                  onStepContinue: () {
                    next();
                  },
                  onStepCancel: () {
                    cancel();
                  },
                  steps: _mySteps()),
        ]));
  }

  List<Step> _mySteps() {
    List<Step> _steps = [
      _validarCurp(),
      _datosAlumno(),
      _datosEscuela(),
      _voucher(),
      _foto(),
      _firma()
    ];
    return _steps;
  }

  Step _validarCurp() {
    return Step(
      title: new Text(_currentStep == 0 ? "Validar alumno" : ''),
      content: Form(
        key: formKeys[0],
        child: Column(
          children: <Widget>[
            TextFormField(
              maxLength: 18,
              validator: (value) => validators.validarCurp(value),
              controller: _curpAlumnoController,
              keyboardType: TextInputType.name,
              inputFormatters: [DigitosLimite(18)],
              decoration: InputDecoration(
                  hintText: '18 digitos',
                  helperText: '',
                  labelText: 'C.U.R.P.'),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: StepState.indexed,
    );
  }

  Step _datosAlumno() {
    return Step(
      title: new Text(_currentStep == 1 ? "Datos del alumno" : ''),
      content: SingleChildScrollView(
        child: Form(
          key: formKeys[1],
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) => validators.notEmptyField(value),
                inputFormatters: [TextoMayusculas()],
                controller: _nombreAlumnoController,
                decoration: InputDecoration(labelText: 'Nombre'),
                enabled: false,
              ),
              TextFormField(
                validator: (value) => validators.notEmptyField(value),
                inputFormatters: [TextoMayusculas()],
                controller: _apellidosAlumnoController,
                decoration: InputDecoration(labelText: 'Apellidos'),
                enabled: false,
              ),
              DropdownButtonFormField(
                isExpanded: true,
                validator: (value) => validators.selectSelected(value),
                hint: Text("Seleccione un Sexo"),
                onChanged: (newValue) {
                  setState(() {
                    sexoSeleccionado = newValue;
                  });
                },
                items: [
                  DropdownMenuItem(
                      value: "H",
                      child: Text("HOMBRE"),),
                  DropdownMenuItem(
                      value: "M",
                      child: Text("MUJER"),),
                ]
              ),
              TextFormField(
                validator: (value) =>
                    validators.validateEmail(value), //notEmptyField(value),
                inputFormatters: [TextoMinusculas()],
                controller: _correoAlumnoController,
                decoration: InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                validator: (value) => validators.validateCellphone(value),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [TextoMayusculas()],
                controller: _celularAlumnoController,
                decoration: InputDecoration(labelText: 'Celular'),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
      isActive: _currentStep >= 1,
      state: StepState.complete,
    );
  }

  Step _datosEscuela() {
    Size size = MediaQuery.of(context).size;
    return Step(
      title: new Text(_currentStep == 2 ? "Datos de la escuela" : ''),
      content: SingleChildScrollView(
        child: Form(
          key: formKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                inputFormatters: [TextoMayusculas()],
                controller: _matriculaAlumnoControler,
                decoration: InputDecoration( 
                    labelText: 'Número de control    (opcional)', hintText: ''),
              ),
              DropdownButtonFormField(
                isExpanded: true,
                validator: (value) => validators.selectSelected(value),
                hint: Text("Seleccione una especialidad"),
                onChanged: (newValue) {
                  setState(() {
                    especialidadSeleccionada = newValue;
                  });
                },
                items: _especialidades.map((especialidadItem) {
                  return DropdownMenuItem(
                      value: especialidadItem['carrera'],
                      child: Text(especialidadItem['carrera']));
                }).toList(),
              ),
              Container(
                width: size.width * 8,
                child: DropdownButtonFormField(
                  validator: (value) => validators.selectSelected(value),
                  hint: Text("Seleccione un semestre"),
                  onChanged: (newValue) {
                    setState(() {
                      semestreSeleccionado = newValue;
                    });
                  },
                  items: _semestres.map((semestreItem) {
                    return DropdownMenuItem(
                        value: semestreItem['semestre'],
                        child: Text(semestreItem['semestre']));
                  }).toList(),
                ),
              ),
              Container(
                width: size.width * 8,
                child: DropdownButtonFormField(
                  validator: (value) => validators.selectSelected(value),
                  hint: Text("Seleccione un grupo"),
                  onChanged: (newValue) {
                    setState(() {
                      grupoSeleccionado = newValue;
                    });
                  },
                  items: _grupos.map((grupoItem) {
                    return DropdownMenuItem(
                        value: grupoItem['grupo'],
                        child: Text(grupoItem['grupo']));
                  }).toList(),
                ),
              ),
              Container(
                width: size.width * 8,
                child: DropdownButtonFormField(
                  validator: (value) => validators.selectSelected(value),
                  hint: Text("Seleccione un turno"),
                  onChanged: (newValue) {
                    setState(() {
                      turnoSeleccionado = newValue;
                    });
                  },
                  items: _turnos.map((turnoItem) {
                    return DropdownMenuItem(
                        value: turnoItem['turno'],
                        child: Text(turnoItem['turno']));
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
      isActive: _currentStep >= 2,
      state: StepState.complete,
    );
  }

  Step _voucher() {
    return Step(
        isActive: _currentStep >= 3,
        state: StepState.complete,
        title: Text(_currentStep == 3 ? "Foto voucher" : ''),
        content: Form(
          key: formKeys[3],
          child: Stack(
            children: <Widget>[
              _mostrarVoucher(),
              Positioned(
                bottom: 5,
                right: 5,
                child: MaterialButton(
                    color: AppColors.morenaColor,
                    padding: EdgeInsets.all(0),
                    minWidth: 10,
                    onPressed: () {
                      _tomarVoucher();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(22)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 1)),
                          borderRadius: BorderRadius.circular(22)),
                      child: Center(
                          child: Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                      )),
                    )),
              ),
            ],
          ),
        ));
  }
  Step _foto() {
    return Step(
        isActive: _currentStep >= 4,
        state: StepState.complete,
        title: Text(_currentStep == 4 ? "Fotografía" : ''),
        content: Form(
          key: formKeys[4],
          child: Stack(
            children: <Widget>[
              _mostrarFoto(),
              Positioned(
                bottom: 5,
                right: 5,
                child: MaterialButton(
                    color: AppColors.morenaColor,
                    padding: EdgeInsets.all(0),
                    minWidth: 10,
                    onPressed: () {
                      _tomarFoto();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(22)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 1)),
                          borderRadius: BorderRadius.circular(22)),
                      child: Center(
                          child: Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                      )),
                    )),
              ),
            ],
          ),
        ));
  }

  Step _firma() {
    return Step(
        isActive: _currentStep >= 5,
        state: StepState.complete,
        title: Text(_currentStep == 5 ? "Firma" : ''),
        content: Form(
          key: formKeys[5],
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              //SIGNATURE CANVAS
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Signature(
                  controller: _signController,
                  height: 90,
                  backgroundColor: Colors.white,
                ),
              ),
              //OK AND CLEAR BUTTONS
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(207, 216, 220, 1)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    /* IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() => _signController.clear());
                      },
                    ), */

                    FlatButton(
                      color: Colors.transparent,
                      onPressed: () {
                        setState(() => _signController.clear());
                      },
                      child: const Text(
                        'Borrar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget showLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            backgroundColor: Color.fromRGBO(236, 186, 17, 1),
            valueColor: AlwaysStoppedAnimation(Colors.green),
            strokeWidth: 5,
          )
        ],
      ),
    );
  }


  Future<bool> procesarFirma() async {
    if (_signController.isNotEmpty) {
      return true;
    }
    return false;
  }

  _tomarFoto() async {
    final _picker = ImagePicker();

    final pickedFile = await _picker.getImage(source: ImageSource.camera);
    //foto = await ImagePicker.pickImage(source: ImageSource.camera);
    //
    foto = File(pickedFile.path);

    if (foto != null) {
      //limpieza
    }

    setState(() {
      foto1 = "confoto";
      //foto = File(pickedFile.path);
    });
  }

  Widget _mostrarFoto() {
    if (foto != null) {
      return Center(
        child: Image(
          image: FileImage(foto /* ?? 'assets/img/no-image.png'  */),
          height: 300.0,
          fit: BoxFit.cover,
        ),
      );
    }
    return foto1 == ""
        ? Image.asset('assets/img/no-image-alumno.png')
        : Image.network(foto1);
  }

  _tomarVoucher() async {
    final _picker = ImagePicker();

    final pickedFile = await _picker.getImage(source: ImageSource.camera);
    //foto = await ImagePicker.pickImage(source: ImageSource.camera);
    //
    voucher = File(pickedFile.path);

    if (voucher != null) {
      //limpieza
    }

    setState(() {
      voucher1 = "conVouhcer";
      //foto = File(pickedFile.path);
    });
  }

  Widget _mostrarVoucher() {
    if (voucher != null) {
      return Center(
        child: Image(
          image: FileImage(voucher /* ?? 'assets/img/no-image.png'  */),
          height: 300.0,
          fit: BoxFit.cover,
        ),
      );
    }
    return voucher1 == ""
        ? Image.asset('assets/img/no-image-voucher.png')
        : Image.network(voucher1);
  }


}
