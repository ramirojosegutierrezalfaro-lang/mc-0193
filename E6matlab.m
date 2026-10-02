%% ============================================================
% ANALISIS ESTADISTICO - ESCENARIO E6
%
% Payloads operativos:
% 32, 40, 50 y 51 bytes
%
% Archivos:
% resultados_E6-32.csv
% resultados_E6-40.csv
% resultados_E6-50.csv
% resultados_E6-51.csv
%
% Indicadores:
% - DER
% - Throughput
% - Latencia
% - Consumo energetico
%
% Estadisticos:
% - Promedio
% - Desviacion estandar
%
% ============================================================

clear;
clc;
close all;

%% ------------------------------------------------------------
% 1. Configuracion
% ------------------------------------------------------------

payloads = [32 40 50 51];

numPayloads = length(payloads);

%% ------------------------------------------------------------
% 2. Inicializar variables
% ------------------------------------------------------------

DER_promedio = zeros(numPayloads,1);
DER_desv = zeros(numPayloads,1);

Throughput_promedio = zeros(numPayloads,1);
Throughput_desv = zeros(numPayloads,1);

Latencia_promedio = zeros(numPayloads,1);
Latencia_desv = zeros(numPayloads,1);

Consumo_promedio = zeros(numPayloads,1);
Consumo_desv = zeros(numPayloads,1);

%% ------------------------------------------------------------
% 3. Leer archivos CSV
% ------------------------------------------------------------

for i = 1:numPayloads

    payload = payloads(i);

    % Nombre del archivo
    archivo = sprintf('resultados_E6-%d.csv', payload);

    fprintf('\n============================================\n');
    fprintf('PAYLOAD: %d BYTES\n', payload);
    fprintf('ARCHIVO: %s\n', archivo);
    fprintf('============================================\n');

    %% --------------------------------------------------------
    % Verificar existencia del archivo
    % --------------------------------------------------------

    if ~isfile(archivo)

        warning('No se encontro el archivo: %s', archivo);

        continue;

    end

    %% --------------------------------------------------------
    % Leer archivo
    % --------------------------------------------------------

    datos = readtable(archivo);

    %% --------------------------------------------------------
    % Mostrar datos
    % --------------------------------------------------------

    disp(datos);

    %% --------------------------------------------------------
    % Verificar numero de replicas
    % --------------------------------------------------------

    fprintf('Numero de replicas encontradas: %d\n', height(datos));

    %% --------------------------------------------------------
    % Calcular promedio
    % --------------------------------------------------------

    DER_promedio(i) = mean(datos.DER, 'omitnan');

    Throughput_promedio(i) = ...
        mean(datos.Throughput, 'omitnan');

    Latencia_promedio(i) = ...
        mean(datos.Latencia, 'omitnan');

    Consumo_promedio(i) = ...
        mean(datos.Consumo, 'omitnan');

    %% --------------------------------------------------------
    % Calcular desviacion estandar
    %
    % std(...,0) utiliza n-1 como denominador.
    % Esto corresponde a la desviacion estandar muestral.
    % --------------------------------------------------------

    DER_desv(i) = ...
        std(datos.DER, 0, 'omitnan');

    Throughput_desv(i) = ...
        std(datos.Throughput, 0, 'omitnan');

    Latencia_desv(i) = ...
        std(datos.Latencia, 0, 'omitnan');

    Consumo_desv(i) = ...
        std(datos.Consumo, 0, 'omitnan');

end

%% ============================================================
% 4. Crear tabla estadistica
% ============================================================

Resultados = table( ...
    payloads', ...
    DER_promedio, ...
    DER_desv, ...
    Throughput_promedio, ...
    Throughput_desv, ...
    Latencia_promedio, ...
    Latencia_desv, ...
    Consumo_promedio, ...
    Consumo_desv, ...
    'VariableNames', { ...
    'Payload_bytes', ...
    'DER_promedio', ...
    'DER_desv', ...
    'Throughput_promedio', ...
    'Throughput_desv', ...
    'Latencia_promedio', ...
    'Latencia_desv', ...
    'Consumo_promedio', ...
    'Consumo_desv'});

%% ============================================================
% 5. Mostrar tabla final
% ============================================================

fprintf('\n\n');
fprintf('============================================================\n');
fprintf('       ESTADISTICOS DESCRIPTIVOS - ESCENARIO E6\n');
fprintf('============================================================\n');

disp(Resultados);

%% ============================================================
% 6. Guardar tabla
% ============================================================

writetable(Resultados, ...
    'resumen_estadistico_E6.csv');

fprintf('\nTabla guardada como:\n');
fprintf('resumen_estadistico_E6.csv\n');

%% ============================================================
% 7. GRAFICO DER
% ============================================================

figure;

bar(payloads, DER_promedio);

xlabel('Tamaño de payload (bytes)');
ylabel('DER promedio (%)');

title('DER promedio según tamaño de payload - E6');

grid on;

%% ============================================================
% 8. GRAFICO THROUGHPUT
% ============================================================

figure;

bar(payloads, Throughput_promedio);

xlabel('Tamaño de payload (bytes)');
ylabel('Throughput promedio (kbps)');

title('Throughput promedio según tamaño de payload - E6');

grid on;

%% ============================================================
% 9. GRAFICO LATENCIA
% ============================================================

figure;

bar(payloads, Latencia_promedio);

xlabel('Tamaño de payload (bytes)');
ylabel('Latencia promedio (ms)');

title('Latencia promedio según tamaño de payload - E6');

grid on;

%% ============================================================
% 10. GRAFICO CONSUMO
% ============================================================

figure;

bar(payloads, Consumo_promedio);

xlabel('Tamaño de payload (bytes)');
ylabel('Consumo energético promedio (J)');

title('Consumo energético promedio según tamaño de payload - E6');

grid on;

%% ============================================================
% 11. DER + DESVIACION ESTANDAR
% ============================================================

figure;

errorbar( ...
    payloads, ...
    DER_promedio, ...
    DER_desv, ...
    'o-', ...
    'LineWidth', 1.5);

xlabel('Tamaño de payload (bytes)');
ylabel('DER (%)');

title('DER promedio y desviación estándar - E6');

grid on;

%% ============================================================
% 12. THROUGHPUT + DESVIACION ESTANDAR
% ============================================================

figure;

errorbar( ...
    payloads, ...
    Throughput_promedio, ...
    Throughput_desv, ...
    'o-', ...
    'LineWidth', 1.5);

xlabel('Tamaño de payload (bytes)');
ylabel('Throughput (kbps)');

title('Throughput promedio y desviación estándar - E6');

grid on;

%% ============================================================
% 13. LATENCIA + DESVIACION ESTANDAR
% ============================================================

figure;

errorbar( ...
    payloads, ...
    Latencia_promedio, ...
    Latencia_desv, ...
    'o-', ...
    'LineWidth', 1.5);

xlabel('Tamaño de payload (bytes)');
ylabel('Latencia (ms)');

title('Latencia promedio y desviación estándar - E6');

grid on;

%% ============================================================
% 14. CONSUMO + DESVIACION ESTANDAR
% ============================================================

figure;

errorbar( ...
    payloads, ...
    Consumo_promedio, ...
    Consumo_desv, ...
    'o-', ...
    'LineWidth', 1.5);

xlabel('Tamaño de payload (bytes)');
ylabel('Consumo energético (J)');

title('Consumo energético promedio y desviación estándar - E6');

grid on;

%% ============================================================
% FIN DEL ANALISIS
% ============================================================

fprintf('\n============================================================\n');
fprintf('ANALISIS ESTADISTICO DE E6 FINALIZADO\n');
fprintf('============================================================\n');