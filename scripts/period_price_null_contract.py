from pathlib import Path
import subprocess,json,hashlib
import tempfile
b=Path(tempfile.mkdtemp(prefix='period-price-contract-')); w=b/'ios-period-harness';w.mkdir(exist_ok=True)
repo=str(Path(__file__).resolve().parents[1])
source=(Path(repo)/'ios/PurchasesHybridCommon/PurchasesHybridCommon/StoreProduct+HybridAdditions.swift').read_text()
(w/'StoreProduct+HybridAdditions.swift').write_text(source)
# Dependency declarations supply nullable product properties; serialization uses the SDK mapper.
(w/'RevenueCat.swift').write_text('''import Foundation
public enum ProductCategory { case nonSubscription, subscription }
public enum ProductType { case consumable, nonConsumable, nonRenewableSubscription, autoRenewableSubscription }
public struct SubscriptionPeriod { public enum Unit { case day, week, month, year }; public var unit: Unit; public var value: Int }
public struct Discount { public var rc_dictionary: [String:Any] { [:] } }
public struct InstallmentsInfo {
 public enum BillingPlanType {case upFront, monthly, unknown}
 public var commitmentInstallmentsCount = 12
 public var commitmentInstallmentPeriod: SubscriptionPeriod
 public var installmentBillingPrice: Decimal = 1
 public var installmentBillingDisplayPrice = "$1"
 public var commitmentTotalPeriod: SubscriptionPeriod
 public var commitmentTotalPrice: Decimal = 12
 public var commitmentTotalDisplayPrice = "$12"
 public var billingPlanType = BillingPlanType.monthly
}
public class StoreProduct: NSObject {
 public var currencyCode: String? = "USD"
 public var localizedDescription = "fixture"
 public var productIdentifier = "lifetime"
 public var id = "lifetime"
 public var priceDecimalNumber: NSDecimalNumber { price }
 public var installmentsInfo: InstallmentsInfo?
 public var price: NSDecimalNumber = 19.99
 public var localizedPriceString = "$19.99"
 public var localizedTitle = "Lifetime"
 public var pricePerWeek: NSDecimalNumber?
 public var pricePerMonth: NSDecimalNumber?
 public var pricePerYear: NSDecimalNumber?
 public var localizedPricePerWeek: String?
 public var localizedPricePerMonth: String?
 public var localizedPricePerYear: String?
 public var introductoryDiscount: Discount?
 public var discounts: [Discount] = []
 public var subscriptionPeriod: SubscriptionPeriod?
 public var productCategory = ProductCategory.nonSubscription
 public var productType = ProductType.nonConsumable
}
''')
(w/'Aliases.swift').write_text('import RevenueCat\ntypealias SubscriptionPeriod = RevenueCat.SubscriptionPeriod\n')
(w/'main.swift').write_text('''import Foundation
import RevenueCat
let p = StoreProduct()
let fields = ["pricePerWeek", "pricePerMonth", "pricePerYear", "pricePerWeekString", "pricePerMonthString", "pricePerYearString"]
let result = p.rc_dictionary
let missing = fields.filter { result[$0] == nil }
let nulls = fields.filter { result[$0] is NSNull }
p.pricePerWeek = 1; p.pricePerMonth = 2; p.pricePerYear = 24
p.localizedPricePerWeek = "$1"; p.localizedPricePerMonth = "$2"; p.localizedPricePerYear = "$24"
let present = fields.filter { p.rc_dictionary[$0] != nil }
let summary: [String:Any] = ["missingFields":missing,"nullFields":nulls,"presentControlFields":present,"expectedNullCount":6]
print(String(data:try JSONSerialization.data(withJSONObject:summary,options:[.sortedKeys]),encoding:.utf8)!)
''')
def run(args):
 r=subprocess.run(args,capture_output=True,text=True)
 if r.returncode: print(r.stderr); r.check_returncode()
 return r
run(['xcrun','swiftc','-emit-module','-emit-library','-module-name','RevenueCat',str(w/'RevenueCat.swift'),'-emit-module-path',str(w/'RevenueCat.swiftmodule'),'-o',str(w/'libRevenueCat.dylib')])
run(['xcrun','swiftc','-I',str(w),'-L',str(w),'-lRevenueCat','-Xlinker','-rpath','-Xlinker',str(w),str(w/'Aliases.swift'),str(w/'StoreProduct+HybridAdditions.swift'),str(w/'main.swift'),'-o',str(w/'repro')])
r=run([str(w/'repro')]);d=json.loads(r.stdout);d.update(commit=subprocess.check_output(['git','-C',repo,'rev-parse','HEAD'],text=True).strip(),sourceSHA256=hashlib.sha256(source.encode()).hexdigest(),scope='Current working-tree production mapper; synthetic product properties via dependency shim; host Foundation execution, not a full iOS app.')
assert len(d['missingFields'])==0 and len(d['nullFields'])==6 and len(d['presentControlFields'])==6, d
(b/'ios-period-current-results.json').write_text(json.dumps(d,indent=2));print(json.dumps(d,indent=2))
