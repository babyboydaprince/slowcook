import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlowCook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late Future<List<User>> _users;

  @override
  void initState() {
    super.initState();
    _users = apiService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slow Cook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          apiService.createUser(
                            User(
                              id: 0, // ID will be set by the backend
                              username: _usernameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          ).then((value) {
                            setState(() {
                              _users = apiService.getUsers();
                            });
                          });
                        }
                      },
                      child: const Text('Create User'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _users,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No users found'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final user = snapshot.data![index];
                        return ListTile(
                          title: Text(user.username),
                          subtitle: Text(user.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _usernameController.text = user.username;
                                  _emailController.text = user.email;
                                  _passwordController.text = user.password;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Update User'),
                                        content: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              TextFormField(
                                                controller: _usernameController,
                                                decoration: const InputDecoration(labelText: 'Username'),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter a username';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              TextFormField(
                                                controller: _emailController,
                                                decoration: const InputDecoration(labelText: 'Email'),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter an email';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              TextFormField(
                                                controller: _passwordController,
                                                decoration: const InputDecoration(labelText: 'Password'),
                                                obscureText: true,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter a password';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!.validate()) {
                                                apiService.updateUser(
                                                  User(
                                                    id: user.id,
                                                    username: _usernameController.text,
                                                    email: _emailController.text,
                                                    password: _passwordController.text,
                                                  ),
                                                ).then((value) {
                                                  setState(() {
                                                    _users = apiService.getUsers();
                                                  });
                                                  Navigator.of(context).pop();
                                                });
                                              }
                                            },
                                            child: const Text('Update'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  apiService.deleteUser(user.id).then((value) {
                                    setState(() {
                                      _users = apiService.getUsers();
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


//### Step 5: Running the Go Server and Flutter App

//1. **Run the Go Server**:
//- Open a terminal and navigate to your `go_backend` directory.
//- Run the Go server using:
//```bash
//go run main.go
//```

//2. **Run the Flutter App**:
//- Open another terminal or use the terminal in Android Studio.
//- Navigate to your Flutter project directory.
//- Run the Flutter app using:
//```bash
//flutter run
//```

//### Step 6: Open and Edit the Project in Android Studio

//1. **Open the Flutter Project**:
//- In Android Studio, go to `File` > `Open` and navigate to your Flutter project directory.
//- Select the project and click `Open`.

//2. **Use the UI Design Tools**:
//- You can use the built-in tools in Android Studio to edit the Flutter UI.
//- Make sure you are in the `lib` directory to edit the Dart files and use the Flutter UI design tools.

//### Database Consideration
//In the provided example, SQLite is used for simplicity and because it's widely supported and used in Android apps.

//By following these steps, you should have a basic CRUD app with a Flutter frontend and a Go backend. If you have any specific questions or need further assistance, feel free to ask!

