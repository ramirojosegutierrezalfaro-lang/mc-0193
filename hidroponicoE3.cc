#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/mobility-module.h"
#include "ns3/lorawan-module.h"
#include "ns3/energy-module.h"
#include <chrono>
#include <ctime>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <fstream>
using namespace ns3;
using namespace lorawan;
NS_LOG_COMPONENT_DEFINE("HidroponicoE3");
int main(int argc, char* argv[])
{
    /***********************
     * ESCENARIO E2
     ***********************/
    uint32_t nDevices = 20;
    uint32_t nGateways = 1;
    double radius = 100;
    double simulationTime = 600;
    uint32_t packetSize = 64;
    uint32_t appPeriod = 60;

    /***********************
     * EJECUCIÓN / RÉPLICA
     ***********************/
    uint32_t run = 1;

    CommandLine cmd;

    cmd.AddValue(
        "run",
        "Número de ejecución/replica (1-7)",
        run);

    cmd.Parse(argc, argv);

    /***********************
     * VALIDAR RUN
     ***********************/
    if (run < 1 || run > 7)
    {
        std::cerr
            << "ERROR: --run debe estar entre 1 y 7."
            << std::endl;

        return 1;
    }
    /***********************
    * SEMILLA Y RÉPLICA
    ***********************/
    uint32_t seed = 12345;

    RngSeedManager::SetSeed(seed);
    RngSeedManager::SetRun(run);
    /***********************
    * INFORMACIÓN DE EJECUCIÓN
     ***********************/
    auto now = std::chrono::system_clock::now();
    std::time_t startTime =
        std::chrono::system_clock::to_time_t(now);

    std::cout
        << "\n========================================"
        << std::endl;

    std::cout
        << "ESCENARIO E3"
        << std::endl;

    std::cout
        << "EJECUCIÓN: "
        << run
        << " / 7"
        << std::endl;

    std::cout
        << "SEED: "
        << seed
        << std::endl;

    std::cout
        << "INICIO: "
        << std::put_time(
            std::localtime(&startTime),
            "%Y-%m-%d %H:%M:%S")
        << std::endl;

    std::cout
        << "========================================"
        << std::endl;

    std::cout
        << "\nCONFIGURACIÓN E3"
        << std::endl;

    std::cout
        << "Nodos sensores     = "
        << nDevices
        << std::endl;

    std::cout
        << "Gateways           = "
        << nGateways
        << std::endl;

    std::cout
        << "Radio              = "
        << radius
        << " m"
        << std::endl;

    std::cout
        << "Tiempo simulación  = "
        << simulationTime
        << " s"
        << std::endl;

    std::cout
        << "Tamaño paquete     = "
        << packetSize
        << " bytes"
        << std::endl;

    std::cout
        << "Periodo aplicación = "
        << appPeriod
        << " s"
        << std::endl;

    std::cout
        << "========================================"
        << std::endl;

    /***********************
     * CANAL LoRa
     ***********************/
    Ptr<LogDistancePropagationLossModel> loss =
        CreateObject<LogDistancePropagationLossModel>();
    loss->SetPathLossExponent(3.0);
    loss->SetReference(1, 7.7);
    Ptr<PropagationDelayModel> delay =
        CreateObject<ConstantSpeedPropagationDelayModel>();
    Ptr<LoraChannel> channel =
        CreateObject<LoraChannel>(
            loss,
            delay);
    /***********************
     * HELPERS
     ***********************/
    LoraPhyHelper phyHelper;
    phyHelper.SetChannel(channel);
    LorawanMacHelper macHelper;
    LoraHelper helper;
    helper.EnablePacketTracking();
    /***********************
     * NODOS SENSORES
     ***********************/
    NodeContainer endDevices;
    endDevices.Create(nDevices);
    MobilityHelper mobility;
    mobility.SetPositionAllocator(
        "ns3::UniformDiscPositionAllocator",
        "rho",
        DoubleValue(radius));
    mobility.SetMobilityModel(
        "ns3::ConstantPositionMobilityModel");
    mobility.Install(endDevices);
    /***********************
    * TOPOLOGÍA - SENSORES
    ***********************/
    std::cout
        << "\n===== TOPOLOGÍA - SENSORES ====="
        << std::endl;

    for (uint32_t i = 0; i < endDevices.GetN(); i++)
    {
        Ptr<MobilityModel> mobilityModel =
            endDevices.Get(i)->GetObject<MobilityModel>();

        Vector position =
            mobilityModel->GetPosition();

        std::cout
            << "Nodo "
            << i
            << ": X = "
            << position.x
            << " m, Y = "
            << position.y
            << " m, Z = "
            << position.z
            << " m"
            << std::endl;
    }

    /***********************
     * ENERGIA
     ***********************/
    BasicEnergySourceHelper energySource;
    energySource.Set(
        "BasicEnergySourceInitialEnergyJ",
        DoubleValue(10000));
    energy::EnergySourceContainer sources;
    sources =
        energySource.Install(endDevices);
    /***********************
     * INSTALAR LoRa END DEVICES
     ***********************/
    Ptr<LoraDeviceAddressGenerator> addrGen =
        CreateObject<LoraDeviceAddressGenerator>(
            54,
            1864);
    macHelper.SetAddressGenerator(addrGen);
    phyHelper.SetDeviceType(
        LoraPhyHelper::ED);
    macHelper.SetDeviceType(
        LorawanMacHelper::ED_A);
    NetDeviceContainer endDeviceNetDevices;
    endDeviceNetDevices =
        helper.Install(
            phyHelper,
            macHelper,
            endDevices);
    /***********************
     * MODELO ENERGETICO LoRa
     ***********************/
    LoraRadioEnergyModelHelper radioEnergy;
    radioEnergy.Install(
        endDeviceNetDevices,
        sources);
    /***********************
     * GATEWAY
     ***********************/
    NodeContainer gateways;
    gateways.Create(nGateways);
    Ptr<ListPositionAllocator> allocator =
        CreateObject<ListPositionAllocator>();
    allocator->Add(
        Vector(0, 0, 15));
    mobility.SetPositionAllocator(
        allocator);
    mobility.Install(gateways);
    /***********************
    * TOPOLOGÍA - GATEWAY
    ***********************/
    std::cout
        << "\n===== TOPOLOGÍA - GATEWAY ====="
        << std::endl;

    for (uint32_t i = 0; i < gateways.GetN(); i++)
    {
        Ptr<MobilityModel> mobilityModel =
            gateways.Get(i)->GetObject<MobilityModel>();

        Vector position =
            mobilityModel->GetPosition();

        std::cout
            << "Gateway "
            << i
            << ": X = "
            << position.x
            << " m, Y = "
            << position.y
            << " m, Z = "
            << position.z
            << " m"
            << std::endl;
    }

    phyHelper.SetDeviceType(
        LoraPhyHelper::GW);
    macHelper.SetDeviceType(
        LorawanMacHelper::GW);
    helper.Install(
        phyHelper,
        macHelper,
        gateways);
    /***********************
     * SPREADING FACTOR
     ***********************/
    std::vector<double> sf9Distribution = {
    0.0,  // DR5 = SF7
    0.0,  // DR4 = SF8
    1.0,  // DR3 = SF9
    0.0,  // DR2 = SF10
    0.0,  // DR1 = SF11
    0.0   // DR0 = SF12
    };

    LorawanMacHelper::SetSpreadingFactorsGivenDistribution(
        endDevices,
        gateways,
        sf9Distribution);
    /***********************
     * APLICACION
     ***********************/
    PeriodicSenderHelper app;
    app.SetPeriod(
        Seconds(appPeriod));
    app.SetPacketSize(
        packetSize);
    ApplicationContainer apps =
        app.Install(endDevices);
    apps.Start(
        Seconds(0));
    apps.Stop(
        Seconds(simulationTime));
    /***********************
     * SIMULACION
     ***********************/
    Simulator::Stop(
        Seconds(simulationTime));
    std::cout
        << "Ejecutando escenario E3..."
        << std::endl;
    Simulator::Run();
    /***********************
     * RESULTADOS ENERGIA
     ***********************/
    std::cout
        << "\n===== ENERGIA ====="
        << std::endl;
    double totalEnergy = 0;
    for (uint32_t i = 0; i < sources.GetN(); i++)
    {
        Ptr<energy::BasicEnergySource> source =
            DynamicCast<energy::BasicEnergySource>
            (
                sources.Get(i)
            );

        double remaining =
            source->GetRemainingEnergy();

        double consumed =
            10000 - remaining;

        totalEnergy += consumed;

        std::cout
            << "Nodo "
            << i
            << " consumo = "
            << consumed
            << " J"
            << std::endl;
    }

    double averageEnergy =
        totalEnergy / nDevices;

    std::cout
        << "Consumo promedio = "
        << averageEnergy
        << " J"
        << std::endl;
    /***********************
     * PACKETS
     ***********************/
    LoraPacketTracker& tracker =
        helper.GetPacketTracker();
    std::string received =
        tracker.CountMacPacketsGlobally(
            Seconds(0),
            Seconds(simulationTime));
    double averageLatency =
        tracker.CalculateAverageLatency(
            Seconds(0),
            Seconds(simulationTime));
    std::stringstream ss(received);

    double sentPackets;
    double receivedPackets;

    ss >> sentPackets >> receivedPackets;

    double throughput =
        (receivedPackets * packetSize * 8.0)
        / simulationTime
        / 1000.0;
    double der =
        (receivedPackets / sentPackets) * 100.0;

    std::cout
        << "\n===== RED ====="
        << std::endl;
    std::cout
        << "Paquetes enviados = "
        << sentPackets
        << std::endl;
    std::cout
        << "Paquetes recibidos = "
        << receivedPackets
        << std::endl;


    std::cout
        << "\n===== COBERTURA ====="
        << std::endl;

    std::cout
        << "Cobertura configurada = "
        << radius
        << " m"
        << std::endl;



    std::cout
        << "DER = "
        << der
        << " %"
        << std::endl;

    std::cout
        << "Throughput = "
        << throughput
        << " kbps"
        << std::endl;

    std::cout
        << "Latencia promedio = "
        << averageLatency * 1000.0
        << " ms"
        << std::endl;

    // =====================================================
    // GUARDAR RESULTADOS PARA MATLAB
    // =====================================================

    std::ofstream file("resultados_E3.csv", std::ios::app);

    if (file.is_open())
    {
        // Escribir encabezado solo si el archivo está vacío
        file.seekp(0, std::ios::end);

        if (file.tellp() == 0)
        {
            file << "Run,DER,Throughput,Latencia,Consumo\n";
        }

        file << run << ","
            << der << ","
            << throughput << ","
            << averageLatency * 1000.0 << ","
            << averageEnergy
            << "\n";

        file.close();
    }
    else
    {
        std::cerr
            << "ERROR: No se pudo abrir resultados_E3.csv"
            << std::endl;
    }

    Simulator::Destroy();
    return 0;
}
