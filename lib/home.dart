import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:ivory_pay_assesment/receipt_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PrinterBluetooth> _devices = [];
  PrinterBluetooth? _device;
  final PrintReceipt pr = PrintReceipt();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      pr.scanForDevices(onScanneComplete: (devices) {
        setState(() {
          _devices = devices;
        });
      });
    });
  }

  selectedDevice(device) {
    setState(() {
      _device = device;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_devices.isNotEmpty)
              Expanded(
                  child: ListView.separated(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final d = _devices[index];
                  return ListTile(
                    title: Text(d.name ?? ''),
                    subtitle: Text(d.address ?? ''),
                    onTap: () {
                      selectedDevice(d);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 20,
                  );
                },
              )),
            ElevatedButton(
              onPressed: _device == null
                  ? null
                  : () {
                      List<ReceiptData> data = [
                        ReceiptData(itemName: 'Milo', quantity: 1, price: 2000),
                        ReceiptData(
                            itemName: 'Peak Milk', quantity: 4, price: 2000),
                        ReceiptData(
                            itemName: 'Bornvita', quantity: 5, price: 5000),
                        ReceiptData(
                            itemName: 'Pampers', quantity: 3, price: 7000),
                        ReceiptData(
                            itemName: 'Indomie', quantity: 6, price: 2000),
                        ReceiptData(
                            itemName: 'Toilet paper', quantity: 7, price: 8000),
                        ReceiptData(
                            itemName: 'Dano Milk', quantity: 1, price: 2000),
                        ReceiptData(
                            itemName: 'Biscuit', quantity: 1, price: 9000),
                        ReceiptData(
                            itemName: 'Close Up', quantity: 1, price: 2000),
                        ReceiptData(itemName: 'Lux', quantity: 2, price: 10000),
                        ReceiptData(itemName: 'Spag', quantity: 8, price: 2000),
                        ReceiptData(
                            itemName: 'Good mama', quantity: 1, price: 2000),
                      ];

                      pr.printReceipt(device: _device!, receiptData: data);
                    },
              child: const Text('Print receior'),
            ),
          ],
        ),
      ),
    );
  }
}
