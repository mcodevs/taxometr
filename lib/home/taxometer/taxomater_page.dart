import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxometr/controller/speed_controller.dart';

class TaxometerPage extends StatelessWidget {
  const TaxometerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpeedController(
        baseAmount: 4000,
        perDistance: 2000,
      ),
      child: const TaxometerView(),
    );
  }
}

class TaxometerView extends StatelessWidget {
  const TaxometerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: "a",
            child: Selector<SpeedController, bool>(
              builder: (context, value, child) {
                return Icon(value ? Icons.play_arrow : Icons.pause);
              },
              selector: (_, provider) => provider.isPaused,
            ),
            onPressed: () async {
              final controller = context.read<SpeedController>();
              if (controller.isPaused) {
                await controller.start();
              } else {
                controller.stop();
              }
            },
          ),
          FloatingActionButton(
            heroTag: "b",
            child: const Icon(Icons.clear),
            onPressed: () {
              context.read<SpeedController>().clear();
            },
          )
        ],
      ),
      body: Center(
        child: Consumer<SpeedController>(builder: (context, value, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(value.amount.toString()),
              ),
              const SizedBox(height: 20),
              Text("Distanse: ${(value.distance / 1000).toStringAsFixed(2)}"),
              Text("Speed: ${value.speed}"),
              Text("Time: ${Duration(seconds: value.seconds).toTime()}"),
              Text("Base amount: ${value.baseAmount}"),
              Text("Per km: ${value.perDistance}"),
            ],
          );
        }),
      ),
    );
  }
}

extension on Duration {
  String toTime() {
    String res = "";
    res += "${inHours != 0 ? "${inHours % 24}".padLeft(2, "0") : "00"}:";
    res += "${inMinutes != 0 ? "${inMinutes % 60}".padLeft(2, "0") : "00"}:";
    res += inSeconds != 0 ? "${inSeconds % 60}".padLeft(2, "0") : "00";
    return res;
  }
}
