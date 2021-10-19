alter table dbo.customer
add RankingId int,
foreign key(RankingId) references dbo.Ranking(Id)