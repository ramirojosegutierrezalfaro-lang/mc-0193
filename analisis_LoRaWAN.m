%% ============================================================
%  ANALISIS DE RESULTADOS LoRaWAN - E1 a E4
%  Indicadores:
%  DER, Throughput, Latencia y Consumo
%  Estadísticos: Promedio y Desviación Estándar
% =============================================================

clear;
clc;
close all;

%% ------------------------------------------------------------
% 1. Nombres de los archivos
% ------------------------------------------------------------

archivos = {
    'resultados_E1.csv'
    'resultados_E2.csv'
    'resultados_E3.csv'
    'resultados_E4.csv'
};

escenarios = {'E1','E2','E3','E4'};

%% ------------------------------------------------------------
% 2. Leer archivos CSV
% ------------------------------------------------------------

datos = cell(4,1);

for i = 1:4

    datos{i} = readtable(archivos{i});

    fprintf('\n=====================================\n');
    fprintf('ESCENARIO %s\n', escenarios{i});
    fprintf('=====================================\n');

    disp(datos{i});

end

%% ------------------------------------------------------------
% 3. Inicializar variables
% ------------------------------------------------------------

DER_promedio = zeros(4,1);
DER_desv = zeros(4,1);

Throughput_promedio = zeros(4,1);
Throughput_desv = zeros(4,1);

Latencia_promedio = zeros(4,1);
Latencia_desv = zeros(4,1);

Consumo_promedio = zeros(4,1);
Consumo_desv = zeros(4,1);

%% ------------------------------------------------------------
% 4. Calcular promedio y desviación estándar
% ------------------------------------------------------------

for i = 1:4

    % DER
    DER_promedio(i) = mean(datos{i}.DER);
    DER_desv(i) = std(datos{i}.DER);

    % Throughput
    Throughput_promedio(i) = mean(datos{i}.Throughput);
    Throughput_desv(i) = std(datos{i}.Throughput);

    % Latencia
    Latencia_promedio(i) = mean(datos{i}.Latencia);
    Latencia_desv(i) = std(datos{i}.Latencia);

    % Consumo
    Consumo_promedio(i) = mean(datos{i}.Consumo);
    Consumo_desv(i) = std(datos{i}.Consumo);

end

%% ------------------------------------------------------------
% 5. Crear tabla de resultados estadísticos
% ------------------------------------------------------------

Resultados = table( ...
    escenarios', ...
    DER_promedio, ...
    DER_desv, ...
    Throughput_promedio, ...
    Throughput_desv, ...
    Latencia_promedio, ...
    Latencia_desv, ...
    Consumo_promedio, ...
    Consumo_desv, ...
    'VariableNames', { ...
    'Escenario', ...
    'DER_promedio', ...
    'DER_desv', ...
    'Throughput_promedio', ...
    'Throughput_desv', ...
    'Latencia_promedio', ...
    'Latencia_desv', ...
    'Consumo_promedio', ...
    'Consumo_desv'});

%% ------------------------------------------------------------
% 6. Mostrar resultados
% ------------------------------------------------------------

fprintf('\n\n============================================\n');
fprintf('     RESULTADOS ESTADISTICOS E1 - E4\n');
fprintf('============================================\n');

disp(Resultados);

%% ------------------------------------------------------------
% 7. Gráfico DER
% ------------------------------------------------------------

figure;

bar(1:4, DER_promedio);
hold on;

errorbar(1:4, DER_promedio, DER_desv, ...
    'k.', 'LineWidth', 1.5, 'MarkerSize', 15);

xticks(1:4);
xticklabels(escenarios);

xlabel('Escenario');
ylabel('DER (%)');
title('DER promedio ± desviación estándar');

grid on;
box on;

hold off;

%% ------------------------------------------------------------
% 8. Gráfico Throughput
% ------------------------------------------------------------

figure;

bar(1:4, Throughput_promedio);
hold on;

errorbar(1:4, Throughput_promedio, Throughput_desv, ...
    'k.', 'LineWidth', 1.5, 'MarkerSize', 15);

xticks(1:4);
xticklabels(escenarios);

xlabel('Escenario');
ylabel('Throughput (kbps)');
title('Throughput promedio ± desviación estándar');

grid on;
box on;

hold off;

%% ------------------------------------------------------------
% 9. Gráfico Latencia
% ------------------------------------------------------------

figure;

bar(1:4, Latencia_promedio);
hold on;

errorbar(1:4, Latencia_promedio, Latencia_desv, ...
    'k.', 'LineWidth', 1.5, 'MarkerSize', 15);

xticks(1:4);
xticklabels(escenarios);

xlabel('Escenario');
ylabel('Latencia (ms)');
title('Latencia promedio ± desviación estándar');

grid on;
box on;

hold off;

%% ------------------------------------------------------------
% 10. Gráfico Consumo
% ------------------------------------------------------------

figure;

bar(1:4, Consumo_promedio);
hold on;

errorbar(1:4, Consumo_promedio, Consumo_desv, ...
    'k.', 'LineWidth', 1.5, 'MarkerSize', 15);

xticks(1:4);
xticklabels(escenarios);

xlabel('Escenario');
ylabel('Consumo energético (J)');
title('Consumo energético promedio ± desviación estándar');

grid on;
box on;

hold off;

%% ------------------------------------------------------------
% 11. Guardar resultados procesados
% ------------------------------------------------------------

writetable(Resultados, 'resumen_E1_E4.csv');

fprintf('\n============================================\n');
fprintf('Resultados guardados correctamente.\n');
fprintf('Archivo: resumen_E1_E4.csv\n');
fprintf('============================================\n');