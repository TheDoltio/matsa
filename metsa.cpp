#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <thread>
#include <chrono>
#include <ctime>

using namespace std;

const string input = "raw_YYMMDDhhmm.dat";
const string output = "cuentas_trad_YYMMDDhhmm.dat";
const int periodo = 10;

// Esta función traduce valores de hexadecimal a decimal, así tenemos un archivo de entrega ya procesado.
int hex_to_dec(string hex) {
    int dec = 0;
    int base = 1;
    
    for (int i = hex.size() - 1; i >= 0; --i) {
        char digit = hex[i];
        if (digit >= '0' && digit <= '9') {
            dec += (digit - '0') * base;
        } else if (digit >= 'A' && digit <= 'F') {
            dec += (digit - 'A' + 10) * base;
        }
        
        base *= 16;
    }
    
    return dec;
}

// Esta función toma el tiempo de la medición de flujo (checa si se registró el tiempo, porque realmente a veces genera esos datos pero no da lecturas de tiempo)
string tiempo (string linea) {
    istringstream stream(linea);
    string token, hora, fecha;
    int columna = 0;
    
    while (stream >> token) {
        if (columna == 10) {
            hora = token;
        } else if (columna == 11) {
            fecha = token;
        }
        ++columna;
    }
    
    // Esta es la línea que se asegura que los valores de hora y fecha son válidos, si no, regresa un valor vacío.
    
    if (fecha.length() == 6) {
        fecha.insert(2, "-");
        fecha.insert(5, "-20"); // Si de alguna forma este detector llega a vivir más de 100 años, habría que subir a -21.
    } else {
        return "";
    }
    
    if (hora.length() >= 6) {
        hora.erase(6, 4);
        hora.insert(2, ":");
        hora.insert(5, ":");
    } else {
        return "";
    }
    
    return fecha + " " + hora;
}

// Ahora, esta línea se encarga de traducir a decimal las incidencias sobre el detector 

string flujo(string line) {
    istringstream stream(line);
    string token;
    vector<string> cuentas;
    long long columna = 0;
    while (stream >> token) {
        if (columna >= 1 && columna <= 5) {
            cuentas.push_back(token);
        }
        ++columna;
    }
        
    for (auto& cuenta : cuentas) {
        cuenta.erase(0, cuenta.find_first_not_of('0'));
            
        if (cuenta.empty()){
            cuenta = "0";
        }
    }
        
    vector<int> datos;
    for (const auto& cuenta : cuentas) {
        datos.push_back(hex_to_dec(cuenta));
    }
        
    ostringstream datos_conseguidos;
    for (size_t i = 0; i < datos.size(); ++i){
        datos_conseguidos << datos[i];
        if (i < datos.size() - 1) {
            datos_conseguidos << " ";
        }
    }
        
    return datos_conseguidos.str();
}

// Esta función es para mantener un registro de qué está pasando en la máquina

void log(bool success) {

    time_t now = time(0);
    tm* ltm = localtime(&now);
    
    char timestamp[20];
    strftime(timestamp, sizeof(timestamp), "%d-%m-%Y %H:%M:%S", ltm);
    
    if (success) {
        cout << "\033[3m\033[44m\033[33m\033[1m" << timestamp << "\033[0m" << "\033[1m\033[32m Datos extraidos y traducidos exitosamente" << "\n";
    } else {
        cout << "\033[3m\033[44m\033[33m\033[1m" << timestamp << "\033[0m" << "\033[1m\033[31m No se encontraron datos que extraer" << "\n";
    }
}

// Esta es la función principal que buscará y traducirá los datos continuamente.      

void proceso_busqueda(const string& input, const string& output) {
    static long long ult_linea = 0;
    string linea;
    vector<string> lineas;
    long long linea_actual = ult_linea;
    bool datos_leidos = false;

    ifstream in(input);
    if (!in) {
        cerr << "\033[1m\033[31mNo se pudo abrir el archivo de entrada.\033[0m" << "\n";
        return;
    }

    in.seekg(ult_linea, ios::beg);
    if (in.fail()) {
        cerr << "\033[1m\033[31mError al mover el puntero de lectura.\033[0m" << "\n";
        in.clear(); 
        in.close();
        return;
    }

    while (getline(in, linea)) {
        linea_actual = in.tellg();
        if (linea_actual == -1) {
            cerr << "\033[1m\033[31mError al obtener la posición del puntero de lectura.\033[0m" << "\n";
            break; 
        }
        lineas.push_back(linea);
    }
    in.close();

    ofstream out(output, ios::app);
    if (!out) {
        cerr << "\033[1m\033[31mNo se pudo abrir el archivo de salida.\033[0m" << "\n";
        return;
    }

    for (size_t i = 0; i < lineas.size(); ++i) {
        if (lineas[i].rfind("DS", 0) == 0) {
            string datos = flujo(lineas[i]);
            string fechas;
            if (i >= 2) {
                fechas = tiempo(lineas[i - 2]);
            }
            if (!fechas.empty()) {
                out << fechas << " " << datos << "\n";
                datos_leidos = true;
            }
        }
    }

    out.close(); 

    if (linea_actual != -1) {
        ult_linea = linea_actual;
    }

    log(datos_leidos);
}

int main() {
    
    cout << "\033[1m\033[35mIniciando la recolección y traducción de datos de flujo\033[0m\n\n";
    
    while (true) {
        proceso_busqueda(input, output);
        
        this_thread::sleep_for(chrono::minutes(periodo));
        
    }
    
    return 0;

}

