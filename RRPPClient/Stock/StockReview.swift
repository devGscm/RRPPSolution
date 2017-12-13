//
//  StockReviewProcess.swift
//   RRPPClient
//
//  Created by 이용민 on 2017. 12. 1..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

//
//  ProductMount.swift
//  RRPPClient
//
//  Created by 이용민 on 2017. 11. 10..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import UIKit
import Material
import Mosaic

class StockReview: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
	
	@IBOutlet weak var lblUserName: UILabel!
	@IBOutlet weak var lblBranchInfo: UILabel!
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	@IBOutlet weak var btnStockReviewId: UIButton!
	@IBOutlet weak var lblProdAssetEpcName: UILabel!
	@IBOutlet weak var lblRealStockCount: UILabel!
	@IBOutlet weak var tvStockReview: UITableView!
	
	
	var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	
	var strStockReviewId: String = ""		/**< 재고조사ID */
	var strProdAssetEpc: String = ""		/**< 장착제품 자산 EPC 코드 */
	var strProdAssetEpcName: String = ""	/**< 장착제품 자산 EPC 명 */
	
	var intOldStockCount			= 0		/**< 전산재고수량 */
	var intRealStockCount 			= 0		/**< 실재고수량 */
	var intCurProcCount 			= 0		/**< 현재처리량 */

	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
	
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*StockReview.viewWillAppear()")
		print("=========================================")
		super.viewWillAppear(animated)
		prepareToolbar()
		
		//RFID를 처리할 델리게이트 지정
		self.initRfid(self as ReaderResponseDelegate )
		
		initViewControl()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*StockReview.viewDidDisappear()")
		print("=========================================")
		arrAssetRows.removeAll()
		arrTagRows.removeAll()
		clsIndicator = nil
		clsDataClient = nil
		
		super.destoryRfid()
		super.viewDidDisappear(animated)
	}
	
	// View관련 컨트롤을 초기화한다.
	func initViewControl()
	{
		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
										 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
		
		lblUserName.text = AppContext.sharedManager.getUserInfo().getUserName()
		lblBranchInfo.text = AppContext.sharedManager.getUserInfo().getBranchName()
		lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
	}
	
	
	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segProductOrderSearch")
		{
			if let clsDialog = segue.destination as? ProductOrderSearch
			{
				clsDialog.ptcDataHandler = self
			}
		}
		else if(segue.identifier == "segTagDetailList")
		{
			if let clsDialog = segue.destination as? TagDetailList
			{
				if let btnDetail = sender as? UIButton
				{
					let clsTagInfo = arrAssetRows[btnDetail.tag]
					
					// 해당 자산코드만 필터링하여 배열을 재생성하여 전달
					let arrData = arrTagRows.filter({ (clsData) -> Bool in
						if(clsData.getAssetEpc() == clsTagInfo.getAssetEpc())
						{
							return true
						}
						return false
					})
					clsDialog.loadData(  arcTagInfo : arrData)
				}
			}
		}
		
		if(segue.identifier == "segOutSignDialog")
		{
			if let clsDialog = segue.destination as? OutSignDialog
			{
				clsDialog.ptcDataHandler = self
			}
		}
		
	}
	
	// 팝업 다이얼로그로 부터 데이터 수신
	func recvData( returnData : ReturnData)
	{
		if(returnData.returnType == "productOrderSearch")
		{
			if(returnData.returnRawData != nil)
			{
				clearUserInterfaceData()
				
				let clsDataRow = returnData.returnRawData as! DataRow
				strStockReviewId	= clsDataRow.getString(name: "makeOrderId") ?? ""
				intRealStockCount	= clsDataRow.getInt(name: "orderWorkCnt") ?? 0
//				intOrderReqCnt	= clsDataRow.getInt(name: "orderReqCnt") ?? 0
//				strProdAssetEpc = clsDataRow.getString(name: "prodAssetEpc")
//				intCurProcCount = intRealStockCount
				
//				print("@@@@@@@@strMakeOrderId=\(strStockReviewId)")
//				print("@@@@@@@@intOrderWorkCnt=\(intRealStockCount)")
				
//				self.btnMakeOrderId.setTitle(strMakeOrderId, for: .normal)
//				self.lblOrderCustName.text = clsDataRow.getString(name: "orderCustName")
//				self.lblOrderCount.text = "\(intOrderWorkCnt)/\(intOrderReqCnt)"
				
				// 새로운 발주번호가 들어면 기존 데이터를 삭제한다.
				clearTagData()
			}
		}
		
		else if(returnData.returnType == "outSignDialog")
		{
			// 상품정보 수정
			if(returnData.returnRawData != nil)
			{
				let clsDataRow = returnData.returnRawData as! DataRow
				let strRemark			= clsDataRow.getString(name: "remark") ?? ""
				let strSignData			= clsDataRow.getString(name: "signData") ?? ""
				let strStockReviewId	= btnStockReviewId.titleLabel?.text ?? ""
				let strWorkerName		= lblUserName.text ?? ""
				
				sendData(workState: Constants.WORK_STATE_COMPLETE, stockReviewId: strStockReviewId, workerName: strWorkerName, remark: strRemark, signData: strSignData)
			}
		}
	}
	

	
	
	// 실사번호 선택
	@IBAction func onStockReviewIdClicked(_ sender: UIButton)
	{
		// TODO
		//self.performSegue(withIdentifier: "segProductOrderSearch", sender: self)
	}
	
	// 데이터를 clear한다.
	func clearTagData()
	{
		arrTagRows.removeAll()
		arrAssetRows.removeAll()
		tvStockReview?.reloadData()
		self.intCurProcCount = self.intRealStockCount
		lblRealStockCount?.text = "\(self.intCurProcCount)"
		super.clearInventory()
	}
	
	func getRfidData( clsTagInfo : RfidUtil.TagInfo)
	{
		let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
		let strSerialNo = clsTagInfo.getSerialNo()
		let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"	// 회사EPC코드 + 자산EPC코드
		
		//------------------------------------------------
		clsTagInfo.setAssetEpc(assetEpc: strAssetEpc)
		if(clsTagInfo.getAssetEpc().isEmpty == false)
		{
			let strAssetName = super.getAssetName(assetEpc: strAssetEpc)
			clsTagInfo.setAssetName(assetName : strAssetName)
			print("@@@@@@@@ AssetName2:\(clsTagInfo.getAssetName() )")
		}
		clsTagInfo.setNewTag(newTag : true)
		clsTagInfo.setReadCount(readCount: 1)
		clsTagInfo.setReadTime(readTime: strCurReadTime)
		//------------------------------------------------
		
		var boolValidAsset = false
		var boolFindSerialNoOverlap = false
		var boolFindAssetTypeOverlap = false
		for clsAssetInfo in super.getAssetList()
		{
			print("@@@@@clsAssetInfo.assetEpc:\(clsAssetInfo.assetEpc)")
			if(clsAssetInfo.assetEpc == strAssetEpc)
			{
				// 자산코드에 등록되어 있는 경우
				print(" 동일한 자산코드 존재")
				boolValidAsset = true
				break;
			}
		}
		print(" 자산코드:\(strAssetEpc), ExistAssetInfo:\(boolValidAsset)")
		if(boolValidAsset == true)
		{
			// Detail 다이얼로그 전달용 태그 리스트
			for clsTagInfo in arrTagRows
			{
				// 같은 시리얼번호가 있는지 체크
				if(clsTagInfo.getSerialNo() == strSerialNo)
				{
					print(" 동일한 시리얼번호 존재")
					boolFindSerialNoOverlap = true
					break;
				}
			}
			
			// 시리얼번호가 중복이 안되어 있다면
			if(boolFindSerialNoOverlap == false)
			{
				// 상세보기용 배열에 추가
				arrTagRows.append(clsTagInfo)
				
				for clsTagInfo in arrAssetRows
				{
					// 같은 자산유형이 있다면 자산유형별로 조회수 증가
					if(clsTagInfo.getAssetEpc() == strAssetEpc)
					{
						boolFindAssetTypeOverlap = true
						let intCurReadCount = clsTagInfo.getReadCount()
						clsTagInfo.setReadCount(readCount: (intCurReadCount + 1))
						break;
					}
				}
				
				// 마스터용 배열에 추가
				if(boolFindAssetTypeOverlap == false)
				{
					arrAssetRows.append(clsTagInfo)
				}
				
				let intCurDataSize = arrTagRows.count
				
				// 발주번호가 있는 경무만 "처리수량/발주수량"을 처리한다.
				
				print("@@@@@@strMakeOrderId:\(strStockReviewId)")
				
//				if(strMakeOrderId.isEmpty == false)
//				{
//					intCurOrderWorkCnt = intOrderWorkCnt + intCurDataSize
//					lblOrderCount.text = "\(intCurOrderWorkCnt)/\(intOrderReqCnt)"
//				}
			}
		}
		DispatchQueue.main.async { self.tvStockReview?.reloadData() }
	}
	
	func sendData(makeOrderId: String, makeLotId: String, workerName: String, remark: String)
	{
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		print("makeOrderId:\(makeOrderId)")
		print("makeLotId:\(makeLotId)")
		print("workerName:\(workerName)")
		print("remark:\(remark)")
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		
		//		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
		//			self.clsIndicator?.hide()
		//		}
		
		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "mountService:executeMountData"
		clsDataClient.removeServiceParam()
		clsDataClient.addServiceParam(paramName: "makeOrderId", value: makeOrderId)
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "makeLotId", value: makeLotId)
		clsDataClient.addServiceParam(paramName: "workerName", value: workerName)
		clsDataClient.addServiceParam(paramName: "remark", value: remark)
		
		let clsDataTable : DataTable = DataTable()
		clsDataTable.Id = "TAG_MOUNT"
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		
		for clsInfo in self.arrTagRows
		{
			if(self.strProdAssetEpc != clsInfo.getAssetEpc())
			{
				self.clsIndicator?.hide()
				
				Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("stock_can_not_processed_because_different_pallet", comment: "품목이 다른 파렛트가 있어 처리 할 수 없습니다."))
				return
			}
			
			let clsDataRow : DataRow = DataRow()
			clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
			clsDataRow.addRow(name:"epcCode", value: clsInfo.getEpcCode())
			clsDataTable.addDataRow(dataRow: clsDataRow)
		}
		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
			self.clsIndicator?.hide()
			if let error = error {
				// 에러처리
				print(error)
				return
			}
			guard let clsResultDataTable = data else {
				print("에러 데이터가 없음")
				return
			}
			
			print("####결과값 처리")
			let clsResultDataRows = clsResultDataTable.getDataRows()
			if(clsResultDataRows.count > 0)
			{
				let clsDataRow = clsResultDataRows[0]
				let strResultCode = clsDataRow.getString(name: "resultCode")
				
				print(" -strResultCode:\(strResultCode!)")
				if(Constants.PROC_RESULT_SUCCESS == strResultCode)
				{
					//비동기 처리 결과에대한  UI에한 처리는 반드시 쓰레드로 처리되어야 한다.
					DispatchQueue.main.async {
						self.clearTagData()
						self.clearUserInterfaceData()
						let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
						self.showSnackbar(message: strMsg)
					}
				}
				else
				{
					let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
					self.showSnackbar(message: strMsg)
				}
			}
			
		})
		
	}
	
	func clearUserInterfaceData()
	{
		intOldStockCount	= 0	/**< 전산재고수량 */
		intCurProcCount 	= 0	/**< 현재 처리량 */
		intRealStockCount	= 0	/**< 실재고수량 */
		strStockReviewId	= ""
		strProdAssetEpc		= ""
		
		// 재고실사번호 초기화
		self.btnStockReviewId.setTitle("", for: .normal)
		
		//유형 초기화
		lblProdAssetEpcName.text = ""
		
		//처리수량 초기화
		lblRealStockCount.text = ""
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrAssetRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let objCell:StockReviewCell = tableView.dequeueReusableCell(withIdentifier: "tvcStockReview", for: indexPath) as! StockReviewCell
		let clsTagInfo = arrAssetRows[indexPath.row]
		
		objCell.lblAssetName.text = clsTagInfo.getAssetName()
		objCell.lblReadCount.text = "\(clsTagInfo.getReadCount())"
		
		objCell.btnDetail.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnDetail.setTitle(String.fontAwesomeIcon(name: .listAlt), for: .normal)
		objCell.btnDetail.tag = indexPath.row
		objCell.btnDetail.addTarget(self, action: #selector(onTagListClicked(_:)), for: .touchUpInside)
		return objCell
	}
	
	// RFID 태그 목록 보기
	@objc func onTagListClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segTagDetailList", sender: self)
	}
	
	// 초기화
	@IBAction func onClearAllClicked(_ sender: UIButton)
	{
		Dialog.show(container: self, viewController: nil,
					title: NSLocalizedString("common_delete", comment: "삭제"),
					message: NSLocalizedString("common_confirm_delete", comment: "전체 데이터를 삭제하시겠습니까?"),
					okTitle: NSLocalizedString("common_confirm", comment: "확인"),
					okHandler: { (_) in
						self.clearTagData()
						super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
		},
					cancelTitle: NSLocalizedString("common_cancel", comment: "확인"), cancelHandler: nil)
	}

	
	// 임시저장
	@IBAction func onTempSaveClick(_ sender: UIButton)
	{
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}

		if(arrAssetRows.count == 0)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		let strStockReviewId = btnStockReviewId.titleLabel?.text
		if(strStockReviewId?.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("stock_enter_your_review_id", comment: "재고실사번호를 입력하여 주십시오."))
			return
		}

		print(" -현처리 수량 : \(intCurProcCount)")
		print(" -전산재고수량 : \(intOldStockCount)")
		
		sendData(workState: Constants.WORK_STATE_WORKING, stockReviewId: self.strStockReviewId, workerName: "", remark: "", signData: "")
	}
	
	
	// 전송
	@IBAction func onSendClicked(_ sender: UIButton)
	{
		print("- UnitID:\(AppContext.sharedManager.getUserInfo().getUnitId())")
		
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}
		
		let strStockReviewId = btnStockReviewId.titleLabel?.text
		if(strStockReviewId?.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("stock_enter_your_review_id", comment: "재고실사번호를 입력하여 주십시오."))
			return
		}
		
		self.performSegue(withIdentifier: "segOutSignDialog", sender: self)
	}
	
	func sendData(workState: String, stockReviewId: String, workerName: String, remark: String, signData: String)
	{
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))

		clsDataClient = DataClient(url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "reviewService:executeStockReviewData"
		clsDataClient.removeServiceParam()

		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		
		clsDataClient.addServiceParam(paramName: "workState", value: workState)
		clsDataClient.addServiceParam(paramName: "stockReviewId", value: stockReviewId)
		
		// 완료전송인경우
		if(Constants.WORK_STATE_COMPLETE == workState)
		{
			clsDataClient.addServiceParam(paramName: "stockReviewState", value: Constants.STOCK_REVIEW_STATE_COMPLETE)
			clsDataClient.addServiceParam(paramName: "workerName", value: workerName)
			clsDataClient.addServiceParam(paramName: "remark", value: remark)
			if(signData.isEmpty == false)
			{
				clsDataClient.addServiceParam(paramName: "signData", value: signData)	// 사인데이터
			}
		}
		
		let clsDataTable : DataTable = DataTable()
		clsDataTable.Id = "STOCK_REVIEW"
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "traceDateTime", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))

		for clsInfo in self.arrTagRows
		{
			if(self.strProdAssetEpc != clsInfo.getAssetEpc())
			{
				self.clsIndicator?.hide()
				
				Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("stock_can_not_processed_because_different_pallet", comment: "품목이 다른 파렛트가 있어 처리 할 수 없습니다."))
				return
			}
			let strTraceDate = DateUtil.localeToUtc(localeDate: clsInfo.getReadTime(), dateFormat: "yyyyMMddHHmmss")
			
			
			let clsDataRow : DataRow = DataRow()
			clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
			clsDataRow.addRow(name:"epcCode", value: clsInfo.getEpcCode())
			clsDataRow.addRow(name:"traceDateTime", value: strTraceDate)
			clsDataTable.addDataRow(dataRow: clsDataRow)
		}
		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
			self.clsIndicator?.hide()
			if let error = error {
				// 에러처리
				print(error)
				return
			}
			guard let clsResultDataTable = data else {
				print("에러 데이터가 없음")
				return
			}
			
			print("####결과값 처리")
			let clsResultDataRows = clsResultDataTable.getDataRows()
			if(clsResultDataRows.count > 0)
			{
				let clsDataRow = clsResultDataRows[0]
				let strResultCode = clsDataRow.getString(name: "resultCode")
				
				print(" -strResultCode:\(strResultCode!)")
				if(Constants.PROC_RESULT_SUCCESS == strResultCode)
				{
					let strSvrProcCount = clsDataRow.getString(name: "procCount")
					let strSvrWorkState = clsDataRow.getString(name: "workState")
					print(" -서버로부터받은처리갯수 : \(String(describing: strSvrProcCount))")
					print(" -서버로부터받은작업처리상태 : \(String(describing: strSvrWorkState))")
					
					
					//비동기 처리 결과에대한  UI에한 처리는 반드시 쓰레드로 처리되어야 한다.
					DispatchQueue.main.async {
						
						self.clearTagData()
						self.clearUserInterfaceData()
					}
					let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
					self.showSnackbar(message: strMsg)

				}
				else
				{
					let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
					self.showSnackbar(message: strMsg)
				}
			}
			
		})
		
	}
	

	
	
	//========================================================================
	// 리더기 관련 이벤트및 처리 시작
	//------------------------------------------------------------------------
	// 리더기 연결 클릭이벤트
	@IBAction func onRfidReaderClicked(_ sender: UIButton)
	{
		if(sender.isSelected == false)
		{
			showSnackbar(message: NSLocalizedString("rfid_connecting_reader", comment: "RFID 리더기에 연결하는 중 입니다."))
			//print(" 리더기 연결")
			super.readerConnect()
		}
		else
		{
			super.readerDisConnect()
		}
	}
	
	//리더기에서 읽어드린 태그에 대한 이벤트 발생처리
	func didReadTagid(_ tagid: String)
	{
		let clsTagInfo = RfidUtil.parse(strData: tagid)
		getRfidData(clsTagInfo: clsTagInfo)
	}
	
	//리더기 연결성공
	func didReaderConnected()
	{
		showSnackbar(message: NSLocalizedString("rfid_connected_reader", comment: "RFID 리더기에 연결되었습니다."))
		changeBtnRfidReader(true)
	}
	
	//리더기 연결종로
	func didReaderDisConnected()
	{
		showSnackbar(message: NSLocalizedString("rfid_connection_terminated", comment: "연결이 종료되었습니다."))
		changeBtnRfidReader(false)
	}
	
	//리더기 연결 타임오바
	func didRederConnectTimeOver()
	{
		showSnackbar(message: NSLocalizedString("rfid_not_connect_reader", comment: "RFID 리더기에 연결할수 없습니다."))
		changeBtnRfidReader(false)
	}
	
	//리더기 연결 여부에 따른 버튼에대한 상태값 변경
	func changeBtnRfidReader(_ isConnected : Bool)
	{
		if(isConnected )
		{
			self.btnRfidReader.isSelected = true
			self.btnRfidReader.backgroundColor = Color.orange.base
			self.btnRfidReader.tintColor = Color.orange.base
			self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_close", comment: "종료"), for: .normal)
		}
		else
		{
			self.btnRfidReader.isSelected = false
			self.btnRfidReader.backgroundColor = Color.blue.base
			self.btnRfidReader.tintColor = Color.white
			self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_connect", comment: "연결"), for: .normal)
		}
	}
	//------------------------------------------------------------------------
	// 리더기 관련 이벤트및 처리 끝
	//========================================================================
}


extension StockReview
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.detail = NSLocalizedString("title_product_mount", comment: "자산등록")
	}
}
