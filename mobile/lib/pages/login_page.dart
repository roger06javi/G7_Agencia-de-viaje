import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();


  final ApiService apiService = ApiService();


  bool isLoading = false;
  bool obscurePassword = true;



  Future<void> iniciarSesion() async {


    // VALIDACIÓN DE CAMPOS

    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {


      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          behavior: SnackBarBehavior.floating,

          backgroundColor: Colors.transparent,

          elevation: 0,

          duration: const Duration(seconds: 3),


          content: Container(

            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),


            decoration: BoxDecoration(

              color: const Color(0xff991B1B),

              borderRadius:
                  BorderRadius.circular(16),


              boxShadow: [

                BoxShadow(

                  color:
                      Colors.black.withOpacity(0.3),

                  blurRadius: 12,

                  offset:
                      const Offset(0, 5),

                )

              ],

            ),



            child: const Row(

              children: [


                Icon(

                  Icons.warning_rounded,

                  color: Colors.white,

                  size: 28,

                ),



                SizedBox(width: 12),



                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    mainAxisSize:
                        MainAxisSize.min,


                    children: [


                      Text(

                        "Campos incompletos",

                        style: TextStyle(

                          color: Colors.white,

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 15,

                        ),

                      ),



                      SizedBox(height: 3),



                      Text(

                        "Necesitamos tus credenciales para continuar.",

                        style: TextStyle(

                          color:
                              Colors.white70,

                          fontSize: 13,

                        ),

                      ),


                    ],

                  ),

                ),

              ],

            ),

          ),

        ),

      );


      return;

    }



    setState(() {

      isLoading = true;

    });



    try {


      final respuesta =
          await apiService.login(

        usernameController.text,

        passwordController.text,

      );



      print(respuesta);



      if (!mounted) return;



      // MENSAJE LOGIN EXITOSO


      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          behavior:
              SnackBarBehavior.floating,


          backgroundColor:
              Colors.transparent,


          elevation: 0,


          duration:
              const Duration(seconds: 2),



          content: Container(


            padding:
                const EdgeInsets.symmetric(

              horizontal: 18,

              vertical: 14,

            ),



            decoration: BoxDecoration(


              color:
                  const Color(0xff166534),



              borderRadius:
                  BorderRadius.circular(16),



              boxShadow: [


                BoxShadow(

                  color:
                      Colors.black.withOpacity(.3),

                  blurRadius: 12,

                  offset:
                      const Offset(0, 5),

                )


              ],


            ),




            child: const Row(

              children: [



                Icon(

                  Icons.check_circle_rounded,

                  color: Colors.white,

                  size: 28,

                ),



                SizedBox(width: 12),



                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    mainAxisSize:
                        MainAxisSize.min,


                    children: [



                      Text(

                        "Acceso exitoso",

                        style: TextStyle(

                          color: Colors.white,

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 15,

                        ),

                      ),



                      SizedBox(height: 3),



                      Text(

                        "Bienvenido a Business Manager. Tu sesión está activa.",

                        style: TextStyle(

                          color:
                              Colors.white70,

                          fontSize: 13,

                        ),

                      ),



                    ],

                  ),

                ),


              ],

            ),


          ),


        ),


      );



      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) => DashboardPage(

            username:
                usernameController.text,

          ),

        ),

      );



    } catch (e) {


      ScaffoldMessenger.of(context).showSnackBar(


        SnackBar(

          behavior:
              SnackBarBehavior.floating,


          backgroundColor:
              Colors.transparent,


          elevation: 0,


          duration:
              const Duration(seconds: 3),



          content: Container(


            padding:
                const EdgeInsets.symmetric(

              horizontal: 18,

              vertical: 14,

            ),



            decoration: BoxDecoration(

              color:
                  const Color(0xff9F1239),


              borderRadius:
                  BorderRadius.circular(16),


            ),



            child: const Row(

              children: [


                Icon(

                  Icons.error_outline,

                  color: Colors.white,

                  size: 28,

                ),


                SizedBox(width: 12),



                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    children: [


                      Text(

                        "Error de acceso",

                        style: TextStyle(

                          color: Colors.white,

                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),



                      Text(

                        "Verifica tu usuario y contraseña.",

                        style: TextStyle(

                          color:
                              Colors.white70,

                          fontSize: 13,

                        ),

                      ),


                    ],

                  ),

                ),


              ],

            ),

          ),

        ),

      );


    } finally {


      if (!mounted) return;


      setState(() {

        isLoading = false;

      });


    }


  }



  @override
  void dispose() {

    usernameController.dispose();

    passwordController.dispose();

    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor:
          const Color(0xff0F172A),


      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(


            padding:
                const EdgeInsets.symmetric(

              horizontal: 28,

              vertical: 20,

            ),



            child: ConstrainedBox(

              constraints:
                  const BoxConstraints(

                maxWidth: 420,

              ),



              child: Container(


                padding:
                    const EdgeInsets.all(30),



                decoration:
                    BoxDecoration(


                  color:
                      const Color(0xff1E293B),



                  borderRadius:
                      BorderRadius.circular(30),



                  border:
                      Border.all(

                    color:
                        Colors.white10,

                  ),



                  boxShadow: [


                    BoxShadow(

                      color:
                          Colors.black.withOpacity(.35),


                      blurRadius:
                          18,


                      offset:
                          const Offset(0, 10),


                    )


                  ],



                ),




                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,


                  children: [



                    // LOGO DEL SISTEMA


                    Container(


                      width:
                          95,


                      height:
                          95,



                      decoration:
                          const BoxDecoration(


                        shape:
                            BoxShape.circle,



                        gradient:
                            LinearGradient(


                          colors: [


                            Color(0xff2563EB),


                            Color(0xff7C3AED),


                          ],



                          begin:
                              Alignment.topLeft,



                          end:
                              Alignment.bottomRight,


                        ),


                      ),




                      child:
                          const Icon(


                        Icons
                            .inventory_2_rounded,


                        size:
                            48,


                        color:
                            Colors.white,


                      ),



                    ),




                    const SizedBox(height: 25),




                    const Text(

                      "Business Manager",


                      style:
                          TextStyle(


                        color:
                            Colors.white,


                        fontSize:
                            28,


                        fontWeight:
                            FontWeight.bold,


                        letterSpacing:
                            .8,


                      ),


                    ),





                    const SizedBox(height: 8),




                    const Text(


                      "Gestiona productos, servicios y categorías desde un solo lugar.",


                      textAlign:
                          TextAlign.center,



                      style:
                          TextStyle(


                        color:
                            Colors.white70,


                        fontSize:
                            15,


                      ),


                    ),





                    const SizedBox(height: 35),





                    // CAMPO USUARIO


                    TextField(


                      controller:
                          usernameController,



                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                      ),




                      decoration:
                          InputDecoration(



                        hintText:
                            "Ingrese su usuario",



                        hintStyle:
                            const TextStyle(

                          color:
                              Colors.grey,

                        ),




                        labelText:
                            "Usuario",




                        labelStyle:
                            const TextStyle(

                          color:
                              Colors.white70,

                        ),




                        prefixIcon:
                            const Icon(


                          Icons
                              .person_outline,


                          color:
                              Colors.lightBlueAccent,


                        ),




                        filled:
                            true,



                        fillColor:
                            const Color(0xff111827),





                        border:
                            OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),



                          borderSide:
                              BorderSide.none,


                        ),




                        enabledBorder:
                            OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),



                          borderSide:
                              BorderSide.none,


                        ),





                        focusedBorder:
                            OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),



                          borderSide:
                              const BorderSide(


                            color:
                                Color(0xff2563EB),


                            width:
                                2,


                          ),


                        ),



                      ),


                    ),




                    const SizedBox(height: 22),





                    // CAMPO CONTRASEÑA


                    TextField(


                      controller:
                          passwordController,



                      obscureText:
                          obscurePassword,




                      style:
                          const TextStyle(


                        color:
                            Colors.white,


                      ),





                      decoration:
                          InputDecoration(


                        hintText:
                            "Ingrese su contraseña",



                        hintStyle:
                            const TextStyle(


                          color:
                              Colors.grey,


                        ),





                        labelText:
                            "Contraseña",




                        labelStyle:
                            const TextStyle(


                          color:
                              Colors.white70,


                        ),





                        prefixIcon:
                            const Icon(


                          Icons.lock_outline,


                          color:
                              Colors.orangeAccent,


                        ),





                        suffixIcon:
                            IconButton(


                          icon:
                              Icon(


                            obscurePassword

                                ? Icons.visibility_off

                                : Icons.visibility,



                            color:
                                Colors.white60,


                          ),




                          onPressed: () {


                            setState(() {


                              obscurePassword =
                                  !obscurePassword;


                            });


                          },


                        ),





                        filled:
                            true,



                        fillColor:
                            const Color(0xff111827),




                        border:
                            OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),



                          borderSide:
                              BorderSide.none,


                        ),




                        enabledBorder:
                            OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),



                          borderSide:
                              BorderSide.none,


                        ),





                        focusedBorder:
                            OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),



                          borderSide:
                              const BorderSide(


                            color:
                                Color(0xff7C3AED),


                            width:
                                2,


                          ),


                        ),



                      ),


                    ),
                                        const SizedBox(height: 30),


                    // BOTÓN LOGIN

                    SizedBox(

                      width:
                          double.infinity,


                      height:
                          55,



                      child:
                          DecoratedBox(



                        decoration:
                            BoxDecoration(


                          borderRadius:
                              BorderRadius.circular(16),



                          gradient:
                              const LinearGradient(


                            colors: [


                              Color(0xff2563EB),


                              Color(0xff7C3AED),


                            ],


                            begin:
                                Alignment.centerLeft,


                            end:
                                Alignment.centerRight,


                          ),



                        ),




                        child:
                            ElevatedButton(



                          onPressed:
                              isLoading

                                  ? null

                                  : iniciarSesion,



                          style:
                              ElevatedButton.styleFrom(



                            backgroundColor:
                                Colors.transparent,



                            shadowColor:
                                Colors.transparent,



                            disabledBackgroundColor:
                                Colors.transparent,



                            shape:
                                RoundedRectangleBorder(



                              borderRadius:
                                  BorderRadius.circular(16),



                            ),


                          ),





                          child:
                              isLoading



                                  ? const SizedBox(



                                      width:
                                          25,



                                      height:
                                          25,



                                      child:
                                          CircularProgressIndicator(



                                        strokeWidth:
                                            3,



                                        color:
                                            Colors.white,



                                      ),



                                    )



                                  :

                                    const Text(


                                      "Iniciar Sesión",



                                      style:
                                          TextStyle(



                                        color:
                                            Colors.white,



                                        fontSize:
                                            17,



                                        fontWeight:
                                            FontWeight.bold,



                                      ),



                                    ),



                        ),



                      ),



                    ),




                    const SizedBox(height: 30),




                    const Divider(


                      color:
                          Colors.white12,


                    ),





                    const SizedBox(height: 15),




                    // PIE DE SISTEMA


                    const Text(



                      "Business Manager • Flutter • Django • JWT",



                      style:
                          TextStyle(



                        color:
                            Colors.grey,



                        fontSize:
                            13,



                      ),



                    ),




                  ],



                ),



              ),



            ),



          ),



        ),



      ),



    );

  }

}