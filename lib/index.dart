import 'dart:io';

import 'package:cron/cron.dart' as cron;
import 'package:fhir/primitive_types/primitive_types.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_at_rest/r4/fhir_request.dart';
import 'package:yaml/yaml.dart';

import 'twilio_flutter.dart';

Future<void> index() async {
  final twilio = loadYaml(await File('/app/lib/twilio.yaml').readAsString());
  final TwilioFlutter _twilioFlutter = TwilioFlutter(
    accountSid: twilio['accountSid'],
    authToken: twilio['authToken'],
    twilioNumber: twilio['twilioNumber'],
  );
  final schedule = cron.Schedule.parse(
    '* '
    '${twilio['hour']} '
    '${twilio['day']} '
    '${twilio['month']} '
    '${twilio['dayOfWeek']}',
  );
  await _makeRequest(twilio, _twilioFlutter);
  final requester = cron.Cron();
  requester.schedule(
      schedule, () async => await _makeRequest(twilio, _twilioFlutter));
}

Future _makeRequest(Map twilio, TwilioFlutter _twilioFlutter) async {
  final fhirUrl = FhirUri(twilio['baseUrl']);
  final checkDate = FhirDateTime(DateTime.now().subtract(Duration(hours: 1)));
  final request = FhirRequest.search(
      base: fhirUrl.value!,
      type: R4ResourceType.CommunicationRequest,
      parameters: [
        'status=active',
        '_lastUpdated=gt$checkDate',
      ]);
  final response = await request.request(headers: {});
  if (response is Bundle && response.entry != null) {
    for (var entry in response.entry!) {
      if (entry.resource?.resourceType == R4ResourceType.CommunicationRequest) {
        var messageBody =
            (entry.resource as CommunicationRequest).payload == null ||
                    (entry.resource as CommunicationRequest).payload!.isEmpty ||
                    (entry.resource as CommunicationRequest)
                            .payload![0]
                            .contentString ==
                        null
                ? 'No message body in Communication Request'
                : (entry.resource as CommunicationRequest)
                    .payload![0]
                    .contentString;

        var send = await _twilioFlutter.sendSMS(
          toNumber: twilio['sendNumber'],
          messageBody: messageBody!,
        );
        if (send == 201) {
          var updatedResource = (entry.resource as CommunicationRequest)
              .copyWith(status: Code('completed'));
          var updateRequest = FhirRequest.update(
              base: fhirUrl.value!, resource: updatedResource);
          await updateRequest.request(headers: {});
        }
      }
    }
  }
}
