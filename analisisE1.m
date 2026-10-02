%% =========================================================
% PROCESAMIENTO DE SALIDA NS-3 - ESCENARIO E1
% =========================================================

clear;
clc;

archivo = 'E1_run1.txt';

fid = fopen(archivo, 'r');

if fid == -1
    error('No se pudo abrir el archivo: %s', archivo);
end

%% =========================================================
% VARIABLES
% =========================================================

nodo          = [];
txTime        = [];
rxTime        = [];
temperatura   = [];
ph            = [];
ce            = [];
nivel         = [];
estado        = {};
payload       = [];

ultimoTxTime = NaN;
ultimoRxTime = NaN;

%% =========================================================
% LECTURA DEL ARCHIVO
% =========================================================

while ~feof(fid)

    linea = fgetl(fid);

    if ~ischar(linea)
        continue;
    end

    %% -----------------------------------------------------
    % TIEMPO DE RECEPCION EN LoraNetDevice
    % ------------------------------------------------------

    token = regexp( ...
        linea, ...
        '\[LoraNetDevice::Receive\] Tiempo = ([\d\.]+) s', ...
        'tokens');

    if ~isempty(token)
        ultimoRxTime = str2double(token{1}{1});
    end

    %% -----------------------------------------------------
    % TIEMPO DE RECEPCION LoRaWAN
    % ------------------------------------------------------

    token = regexp( ...
        linea, ...
        'Tiempo = ([\d\.]+) s', ...
        'tokens');

    if ~isempty(token)

        tiempoDetectado = str2double(token{1}{1});

        % Si la línea corresponde al bloque de monitoreo,
        % se utilizará posteriormente.
        if contains(linea, '[LoraNetDevice::Receive]')
            ultimoRxTime = tiempoDetectado;
        end
    end

    %% -----------------------------------------------------
    % NODO
    % ------------------------------------------------------

    token = regexp( ...
        linea, ...
        '^Nodo = (\d+)', ...
        'tokens');

    if ~isempty(token)

        nodoActual = str2double(token{1}{1});

        %% -------------------------------------------------
        % TEMP
        % -------------------------------------------------

        lineaTemp = fgetl(fid);

        tokenTemp = regexp( ...
            lineaTemp, ...
            'Temp = ([\d\.]+)', ...
            'tokens');

        if ~isempty(tokenTemp)
            tempActual = str2double(tokenTemp{1}{1});
        else
            tempActual = NaN;
        end

        %% -------------------------------------------------
        % PH
        % -------------------------------------------------

        lineaPH = fgetl(fid);

        tokenPH = regexp( ...
            lineaPH, ...
            'PH = ([\d\.]+)', ...
            'tokens');

        if ~isempty(tokenPH)
            phActual = str2double(tokenPH{1}{1});
        else
            phActual = NaN;
        end

        %% -------------------------------------------------
        % CE
        % -------------------------------------------------

        lineaCE = fgetl(fid);

        tokenCE = regexp( ...
            lineaCE, ...
            'CE = ([\d\.]+)', ...
            'tokens');

        if ~isempty(tokenCE)
            ceActual = str2double(tokenCE{1}{1});
        else
            ceActual = NaN;
        end

        %% -------------------------------------------------
        % NIVEL
        % -------------------------------------------------

        lineaNivel = fgetl(fid);

        tokenNivel = regexp( ...
            lineaNivel, ...
            'Nivel = ([\d\.]+)', ...
            'tokens');

        if ~isempty(tokenNivel)
            nivelActual = str2double(tokenNivel{1}{1});
        else
            nivelActual = NaN;
        end

        %% -------------------------------------------------
        % ESTADO
        % -------------------------------------------------

        lineaEstado = fgetl(fid);

        tokenEstado = regexp( ...
            lineaEstado, ...
            'Estado = (.+)', ...
            'tokens');

        if ~isempty(tokenEstado)
            estadoActual = strtrim(tokenEstado{1}{1});
        else
            estadoActual = "";
        end

        %% -------------------------------------------------
        % PAYLOAD
        % -------------------------------------------------

        payloadActual = "";

        % Buscar las siguientes líneas hasta encontrar Payload
        for k = 1:8

            siguiente = fgetl(fid);

            if ~ischar(siguiente)
                break;
            end

            tokenPayload = regexp( ...
                siguiente, ...
                '\| Payload = (.+)', ...
                'tokens');

            if ~isempty(tokenPayload)
                payloadActual = strtrim(tokenPayload{1}{1});
                break;
            end
        end

        %% -------------------------------------------------
        % TIEMPO DEL BLOQUE DE MONITOREO
        % -------------------------------------------------

        % El tiempo de recepción LoRaWAN suele estar justo
        % antes del bloque de monitoreo.
        rxActual = ultimoRxTime;

        %% -------------------------------------------------
        % GUARDAR REGISTRO
        % -------------------------------------------------

        nodo(end+1,1)        = nodoActual;
        
        rxTime(end+1,1)      = rxActual;
        temperatura(end+1,1)= tempActual;
        ph(end+1,1)          = phActual;
        ce(end+1,1)          = ceActual;
        nivel(end+1,1)       = nivelActual;
        estado{end+1,1}      = estadoActual;
        payload{end+1,1}     = payloadActual;

    end

end

fclose(fid);

%% =========================================================
% CREAR TABLA
% =========================================================

TablaDatos = table( ...
    nodo, ...
    rxTime, ...
    temperatura, ...
    ph, ...
    ce, ...
    nivel, ...
    estado, ...
    payload, ...
    'VariableNames', { ...
        'Nodo', ...
        'RX', ...
        'Temperatura_C', ...
        'PH', ...
        'CE_mScm', ...
        'Nivel_pct', ...
        'Estado', ...
        'Payload'});

%% =========================================================
% ORDENAR POR NODO Y TIEMPO
% =========================================================

TablaDatos = sortrows( ...
    TablaDatos, ...
    {'Nodo','RX'});

%% =========================================================
% MOSTRAR RESULTADO
% =========================================================

disp(TablaDatos);

%% =========================================================
% EXPORTAR A CSV
% =========================================================

writetable( ...
    TablaDatos, ...
    'E1_datos_hidroponicos.csv');

fprintf('\nArchivo generado: E1_datos_hidroponicos.csv\n');

%% =========================================================
% RESUMEN POR NODO
% =========================================================

nodos = unique(TablaDatos.Nodo);

Resumen = table();

for i = 1:length(nodos)

    idx = TablaDatos.Nodo == nodos(i);

    fila = table( ...
        nodos(i), ...
        sum(idx), ...
        mean(TablaDatos.Temperatura_C(idx)), ...
        mean(TablaDatos.PH(idx)), ...
        mean(TablaDatos.CE_mScm(idx)), ...
        mean(TablaDatos.Nivel_pct(idx)), ...
        'VariableNames', { ...
            'Nodo', ...
            'Recepciones', ...
            'Temp_Prom_C', ...
            'PH_Prom', ...
            'CE_Prom_mScm', ...
            'Nivel_Prom_pct'});

    Resumen = [Resumen; fila];

end

%% =========================================================
% MOSTRAR RESUMEN
% =========================================================

disp(Resumen);

%% =========================================================
% EXPORTAR RESUMEN
% =========================================================

writetable( ...
    Resumen, ...
    'E1_resumen_por_nodo.csv');