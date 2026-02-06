import 'package:flutter_app/core/consants/api_constants.dart';
import 'package:flutter_app/core/network/api_client.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_advice_request.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_organize_request.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_schedule_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final smartServiceProvider = Provider((ref) => SmartService(ApiClient()));

class SmartService {
  final ApiClient _apiClient;

  SmartService(this._apiClient);

  // smart schedule endpoint
  Future<dynamic> smartSchedule({required SmartScheduleRequest request}) async {
    final response = await _apiClient.postRequest(ApiConstants.smartSched, request.toJson());
    return response.data;
  }
  // smart organize endpoint
  Future<dynamic> smartOrganize({required SmartOrganizeRequest request}) async {
    final response = await _apiClient.postRequest(ApiConstants.smartOrganize, request.toJson());
    return response.data;
  }
  // smart advice endpoint
  Future<dynamic> smartAdvice({required SmartAdviceRequest request}) async {
    final response = await _apiClient.postRequest(ApiConstants.smartAdvice, request.toJson());
    return response.data;
  }
}