SELECT
         C.CustomerID,
       CASE
         WHEN PM.Name = 'Credit Card - Amex' THEN 'American Express'
         WHEN PM.Name = 'Credit Card - Visa' THEN 'Visa'
         WHEN PM.Name = 'Credt Card - MasterCard' THEN 'MasterCard'
         WHEN PM.Name = 'Credit Card - Discover' THEN 'Discover'
         ELSE PM.Name
       END AS [PaymentType],

       [PaymentDateTime],
       [AmountCollected],

       CASE --The System will make this a check box by default this is keep it as a 1 or 0
         WHEN [CardholderPresent] = 1 THEN 1
         WHEN [CardholderPresent] = 0 THEN 0
       END AS [CardholderPresent],

       CASE -- To do a count if not present in excel
         WHEN [CardholderPresent] = 1 THEN 0
         WHEN [CardholderPresent] = 0 THEN 1
       END AS [Inverse],

       CASE
         WHEN PM.Name = 'Credit Card - Amex' THEN 1
         WHEN PM.Name = 'Credit Card - Visa' THEN 1
         WHEN PM.Name = 'Credt Card - MasterCard' THEN 1
         WHEN PM.Name = 'Credit Card - Discover' THEN 1
         ELSE 0
       END AS [IsCreditCard],
	   OP.OrderID


FROM OrderPayment OP
-- Currently moving over to have this work on Customers, for salesmen add users in
-- INNER JOIN Users U
-- ON U.UserID = OP.UserID
JOIN OrderHeader OH 
	ON OH.OrderID = OP.OrderID
JOIN Customer C
	ON OH.CustomerID = C.CustomerID
JOIN PaymentMethod PM
  ON PM.PaymentMethodID = OP.PaymentMethodID


WHERE PaymentDateTime > '2015-01-01 00:00:00' -- pre Q3 2014 data does not incldue exact cards
AND Details IS NULL-- This is an adjustment created by a back-order and does not represent an actual electronic payment.%'
-- To only select Credit Cards add the bottom row
--AND(PM.PaymentMethodID = 5 OR PM.PaymentMethodID = 6  OR PM.PaymentMethodID = 7  OR PM.PaymentMethodID = 11)
AND Amount > 0
AND Deposit = 1 -- This will be checked or someone will get atttacked
AND OP.OrderID IS NOT NULL


ORDER BY PaymentDateTime DESC
