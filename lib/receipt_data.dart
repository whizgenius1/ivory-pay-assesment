import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';

class ReceiptData {
  final int quantity;
  final String itemName;
  final num price;

  ReceiptData({
    required this.quantity,
    required this.itemName,
    required this.price,
  });
}

class PrintReceipt {
  final PrinterBluetoothManager _printerManager = PrinterBluetoothManager();

  scanForDevices({
    required Function(List<PrinterBluetooth>) onScanneComplete,
  }) {
    _printerManager.startScan(const Duration(seconds: 10));
    _printerManager.scanResults.listen((devices) {
      onScanneComplete(devices);
    });
  }

  stopScanningForDevice() {
    _printerManager.stopScan();
  }

  printReceipt({
    required List<ReceiptData> receiptData,
    required PrinterBluetooth device,
    PaperSize? paperSize,
  }) async {
    _printerManager.selectPrinter(device);
    PaperSize paper = paperSize ?? PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    final PosPrintResult res = await _printerManager.printTicket(
        (await testPrintReceipt(
            receiptData: receiptData, paper: paper, profile: profile)));
  }

  testPrintReceipt(
      {required List<ReceiptData> receiptData,
      PaperSize? paper,
      CapabilityProfile? profile}) async {
    num total = 0;
    for (final receiptDatum in receiptData) {
      total += receiptDatum.price * receiptDatum.quantity;
    }
    final Generator ticket = Generator(
        paper ?? PaperSize.mm80, profile ?? await CapabilityProfile.load());
    List<int> bytes = [];

//Company name
    bytes += ticket.text('IvoryPay',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    //address
    bytes += ticket.text(
      '294  Herber Macaulay Way',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += ticket.text(
      'Yaba, Lagos',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += ticket.text(
      'Tel: (234)8155077989',
      styles: const PosStyles(
        align: PosAlign.center,
      ),
    );
    bytes += ticket.text('Web: www.example.com',
        styles: const PosStyles(
          align: PosAlign.center,
        ),
        linesAfter: 1);

//draw horizontal line
    bytes += ticket.hr();
//Item header
    bytes += ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
        text: 'Price',
        width: 2,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
      PosColumn(
        text: 'Total',
        width: 2,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);

//Recipt items
    for (final receiptDatum in receiptData) {
      bytes += ticket.row([
        PosColumn(text: '${receiptDatum.quantity}', width: 1),
        PosColumn(text: receiptDatum.itemName, width: 7),
        PosColumn(
          text: '${receiptDatum.price}',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
        PosColumn(
          text: '${receiptDatum.quantity * receiptDatum.price}',
          width: 2,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
    }
    //draw horizontal line
    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: const PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '$total',
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.hr(ch: '=', linesAfter: 1);

    bytes += ticket.feed(2);
    bytes += ticket.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += ticket.text(timestamp,
        styles: const PosStyles(align: PosAlign.center), linesAfter: 2);

    ticket.feed(2);
    ticket.cut();
    return bytes;
  }
}
